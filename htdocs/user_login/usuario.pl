#!C:/xampp/perl/bin/perl.exe



use strict;
use warnings;
use CGI;
use DBI;
use JSON;

my $cgi = CGI->new;
print $cgi->header('application/json');

# Detalles de conexión a la base de datos
my $db_name = 'polleria';
my $db_user = 'root';
my $db_pass = 'gyunque';
my $db_host = 'localhost';
my $db_port = 3307;

my $dsn = "DBI:mysql:database=$db_name;host=$db_host;port=$db_port";
my $dbh = DBI->connect($dsn, $db_user, $db_pass, {
    RaiseError => 1,
    AutoCommit => 1,
    mysql_enable_utf8 => 1,
}) or die $DBI::errstr;

warn "Conexión exitosa a la base de datos"; # Mensaje de depuración

my $input = $cgi->param('POSTDATA');
my $data = decode_json($input);

my $action = $data->{action};
warn "Acción recibida: " . (defined $action ? $action : "no definida"); # Mensaje de depuración

if (defined $action && $action eq 'listar_ventas') {
    listar_ventas();
} elsif (defined $action && $action eq 'registrar_venta') {
    registrar_venta($data->{productos});
} else {
    warn "Acción no válida: " . (defined $action ? $action : "no definida"); # Mensaje de depuración
    print encode_json({ error => 'Acción no válida' });
}

$dbh->disconnect;

sub listar_ventas {
    my $sth = $dbh->prepare("SELECT Ventas.id, Productos.nombre, Ventas.cantidad, Ventas.total, Ventas.fecha FROM Ventas JOIN Productos ON Ventas.id_producto = Productos.id");
    $sth->execute();
    my @ventas;
    while (my $row = $sth->fetchrow_hashref) {
        push @ventas, $row;
    }
    print encode_json(\@ventas);
}

sub registrar_venta {
    my ($productos) = @_;

    foreach my $producto (@$productos) {
        my $id_producto = $producto->{id};
        my $cantidad = $producto->{cantidad};
        
        warn "Datos recibidos - ID Producto: $id_producto, Cantidad: $cantidad"; # Mensaje de depuración

        # Obtener el precio del producto
        my $sth_precio = $dbh->prepare("SELECT precio FROM Productos WHERE id = ?");
        $sth_precio->execute($id_producto);
        my ($precio) = $sth_precio->fetchrow_array();
        my $total = $cantidad * $precio;

        # Insertar la venta con el total calculado
        my $sth = $dbh->prepare("INSERT INTO Ventas (id_producto, cantidad, total, fecha) VALUES (?, ?, ?, NOW())");
        if ($sth->execute($id_producto, $cantidad, $total)) {
            warn "Venta registrada con éxito"; # Mensaje de depuración
        } else {
            warn "Error al registrar venta: " . $sth->errstr;
            print encode_json({ error => 'Error al registrar venta' });
            return;
        }

        # Actualizar el inventario
        my $sth2 = $dbh->prepare("UPDATE Productos SET cantidad = cantidad - ? WHERE id = ?");
        if ($sth2->execute($cantidad, $id_producto)) {
            warn "Inventario actualizado con éxito"; # Mensaje de depuración
        } else {
            warn "Error al actualizar inventario: " . $sth2->errstr;
            print encode_json({ error => 'Error al actualizar inventario' });
            return;
        }

        # Registrar movimiento de venta en el Kardex
        registrar_movimiento($id_producto, 'Venta', $cantidad);
    }

    print encode_json({ success => 'Venta registrada' });
}

sub registrar_movimiento {
    my ($id_producto, $tipo, $cantidad) = @_;
    my $sth = $dbh->prepare("INSERT INTO MovimientosKardex (id_producto, tipo_movimiento, cantidad, fecha) VALUES (?, ?, ?, NOW())");
    if ($sth->execute($id_producto, $tipo, $cantidad)) {
        warn "Inserción exitosa en MovimientosKardex"; # Mensaje de depuración
    } else {
        warn "Error al insertar datos en MovimientosKardex: " . $sth->errstr;
    }
}
