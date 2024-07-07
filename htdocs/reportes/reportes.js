document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('reporteForm').addEventListener('submit', function(event) {
        event.preventDefault();
        generarReporte();
    });
});

function generarReporte() {
    const fechaInicio = document.getElementById('fechaInicio').value;
    const fechaFin = document.getElementById('fechaFin').value;

    fetch('/cgi-bin/reportes.pl', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            action: 'generar_reporte',
            fechaInicio: fechaInicio,
            fechaFin: fechaFin
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.error) {
            alert('Error: ' + data.error);
        } else {
            mostrarResultados(data.resultados);
        }
    })
    .catch(error => console.error('Error al generar el reporte:', error));
}

function mostrarResultados(resultados) {
    const tabla = document.getElementById('resultadosReporte').getElementsByTagName('tbody')[0];
    tabla.innerHTML = '';
    let totalGeneral = 0;

    resultados.forEach(resultado => {
        const row = tabla.insertRow();
        const fechaCell = row.insertCell(0);
        const montoCell = row.insertCell(1);

        fechaCell.textContent = resultado.fecha;
        montoCell.textContent = resultado.total;

        totalGeneral += parseFloat(resultado.total);
    });

    const totalRow = tabla.insertRow();
    totalRow.insertCell(0).textContent = 'Total General';
    totalRow.insertCell(1).textContent = totalGeneral.toFixed(2);
}
