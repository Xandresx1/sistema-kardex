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

my $action = $cgi->param('action') || '';

if ($action eq 'listar_movimientos') {
    listar_movimientos();
} else {
    print encode_json({ error => 'Acción no válida' });
}

$dbh->disconnect;

sub listar_movimientos {
    my $sth = $dbh->prepare("
        SELECT 
            MovimientosKardex.id,
            Productos.nombre,
            MovimientosKardex.tipo_movimiento,
            MovimientosKardex.cantidad,
            MovimientosKardex.fecha
        FROM 
            MovimientosKardex
        JOIN 
            Productos ON MovimientosKardex.id_producto = Productos.id
    ");
    $sth->execute();
    my @movimientos;
    while (my $row = $sth->fetchrow_hashref) {
        push @movimientos, $row;
    }
    print encode_json(\@movimientos);
}
