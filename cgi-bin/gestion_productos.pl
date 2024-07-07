#!C:/xampp/perl/bin/perl.exe



use strict;
use warnings;
use CGI;
use DBI;
use JSON;

my $cgi = CGI->new;
print $cgi->header('application/json');

# Detalles de conexión a la base de datos
my $db_name = 'kardexpolleria';
my $db_user = 'root';
my $db_pass = 'Plateado';
my $db_host = 'localhost';
my $db_port = 3307;

my $dsn = "DBI:mysql:database=$db_name;host=$db_host;port=$db_port";
my $dbh = DBI->connect($dsn, $db_user, $db_pass, {
    RaiseError => 1,
    AutoCommit => 1,
    mysql_enable_utf8 => 1,
}) or die $DBI::errstr;

warn "Conexión exitosa a la base de datos"; # Mensaje de depuración

my $action = $cgi->param('action');
warn "Acción recibida: " . (defined $action ? $action : "no definida"); # Mensaje de depuración

if (defined $action && $action eq 'listar_productos') {
    listar_productos();
} elsif (defined $action && $action eq 'agregar_producto') {
    agregar_producto();
} elsif (defined $action && $action eq 'eliminar_producto') {
    eliminar_producto();
} elsif (defined $action && $action eq 'actualizar_producto') {
    actualizar_producto();
} else {
    warn "Acción no válida o no definida: " . (defined $action ? $action : "no definida"); # Mensaje de depuración
    print encode_json({ error => 'Acción no válida' });
}

$dbh->disconnect;

sub listar_productos {
    my $sth = $dbh->prepare("SELECT * FROM Productos");
    $sth->execute();
    my @productos;
    while (my $row = $sth->fetchrow_hashref) {
        push @productos, $row;
    }
    print encode_json(\@productos);
}

sub agregar_producto {
    my $nombre = $cgi->param('nombreProducto');
    my $precio = $cgi->param('precioProducto');
    my $cantidad = $cgi->param('cantidadProducto');

    warn "Datos recibidos - Nombre: $nombre, Precio: $precio, Cantidad: $cantidad"; # Mensaje de depuración

    my $sth = $dbh->prepare("INSERT INTO Productos (nombre, precio, cantidad) VALUES (?, ?, ?)");
    if ($sth->execute($nombre, $precio, $cantidad)) {
        warn "Inserción exitosa en Productos"; # Mensaje de depuración
    } else {
        warn "Error al insertar datos en Productos: " . $sth->errstr;
    }

    # Registrar movimiento de ingreso en el Kardex
    my $id_producto = $dbh->{mysql_insertid};
    registrar_movimiento($id_producto, 'Ingreso', $cantidad);

    print encode_json({ success => 'Producto agregado' });
}

sub eliminar_producto {
    my $id = $cgi->param('id');
    my $sth = $dbh->prepare("DELETE FROM Productos WHERE id = ?");
    $sth->execute($id);
    print encode_json({ success => 'Producto eliminado' });
}

sub actualizar_producto {
    my $id = $cgi->param('id');
    my $nombre = $cgi->param('nombreProducto');
    my $precio = $cgi->param('precioProducto');
    my $cantidad = $cgi->param('cantidadProducto');
    my $sth = $dbh->prepare("UPDATE Productos SET nombre = ?, precio = ?, cantidad = ? WHERE id = ?");
    $sth->execute($nombre, $precio, $cantidad, $id);

    # Registrar movimiento de actualización en el Kardex
    registrar_movimiento($id, 'Actualización', $cantidad);

    print encode_json({ success => 'Producto actualizado' });
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
