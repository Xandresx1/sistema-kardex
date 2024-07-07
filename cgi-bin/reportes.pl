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

my $input = $cgi->param('POSTDATA');
warn "Datos recibidos: " . (defined $input ? $input : "No se recibieron datos");

my $data = decode_json($input);
my $action = $data->{action} || '';

if ($action eq 'generar_reporte') {
    generar_reporte($data->{fechaInicio}, $data->{fechaFin});
} else {
    print encode_json({ error => 'Acción no válida' });
}

$dbh->disconnect;

sub generar_reporte {
    my ($fecha_inicio, $fecha_fin) = @_;

    my $sth = $dbh->prepare("
        SELECT DATE(fecha) as fecha, SUM(total) as total
        FROM Ventas
        WHERE fecha BETWEEN ? AND ?
        GROUP BY DATE(fecha)
    ");
    $sth->execute($fecha_inicio, $fecha_fin);

    my @resultados;
    while (my $row = $sth->fetchrow_hashref) {
        push @resultados, $row;
    }

    print encode_json({ resultados => \@resultados });
}
