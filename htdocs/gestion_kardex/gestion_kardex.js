document.addEventListener('DOMContentLoaded', function() {
    cargarProductos();
    cargarMovimientos();
});

function cargarProductos() {
    fetch('../../cgi-bin/gestion_productos.pl?action=listar_productos')
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(data => {
            const productosTable = document.getElementById('productosTable').getElementsByTagName('tbody')[0];
            productosTable.innerHTML = '';
            data.forEach(producto => {
                const row = productosTable.insertRow();
                row.innerHTML = `
                    <td>${producto.nombre}</td>
                    <td>${producto.cantidad}</td>
                `;
            });
        })
        .catch(error => {
            console.error("Error al cargar productos:", error);
            alert("Error al cargar productos: " + error.message);
        });
}

function cargarMovimientos() {
    fetch('../../cgi-bin/gestion_kardex.pl?action=listar_movimientos')
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(data => {
            const movimientosTable = document.getElementById('movimientosTable').getElementsByTagName('tbody')[0];
            movimientosTable.innerHTML = '';
            data.forEach(movimiento => {
                const row = movimientosTable.insertRow();
                row.innerHTML = `
                    <td>${movimiento.nombre}</td>
                    <td>${movimiento.tipo_movimiento}</td>
                    <td>${movimiento.cantidad}</td>
                    <td>${movimiento.fecha}</td>
                `;
            });
        })
        .catch(error => {
            console.error("Error al cargar movimientos:", error);
            alert("Error al cargar movimientos: " + error.message);
        });
}
