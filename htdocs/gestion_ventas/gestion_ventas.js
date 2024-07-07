document.addEventListener('DOMContentLoaded', function() {
    cargarVentas();
    cargarProductos();

    document.getElementById('agregarProducto').addEventListener('click', function(event) {
        event.preventDefault();
        agregarProducto();
    });

    document.getElementById('registrarVenta').addEventListener('click', function(event) {
        event.preventDefault();
        registrarVenta();
    });
});

function cargarVentas() {
    fetch('/cgi-bin/gestion_ventas.pl?action=listar_ventas')
        .then(response => response.json())
        .then(data => {
            const ventasTable = document.getElementById('ventasTable').getElementsByTagName('tbody')[0];
            ventasTable.innerHTML = '';
            data.forEach(venta => {
                const row = ventasTable.insertRow();
                row.innerHTML = `
                    <td>${venta.nombre}</td>
                    <td>${venta.cantidad}</td>
                    <td>${venta.fecha}</td>
                `;
            });
        });
}

function cargarProductos() {
    fetch('/cgi-bin/gestion_productos.pl?action=listar_productos')
        .then(response => response.json())
        .then(data => {
            const productoVenta = document.getElementById('productoVenta');
            data.forEach(producto => {
                const option = document.createElement('option');
                option.value = producto.id;
                option.text = producto.nombre;
                option.dataset.precio = producto.precio;
                productoVenta.add(option);
            });
        });
}

function agregarProducto() {
    const productoSelect = document.getElementById('productoVenta');
    const productoId = productoSelect.value;
    const productoNombre = productoSelect.options[productoSelect.selectedIndex].text;
    const productoPrecio = parseFloat(productoSelect.options[productoSelect.selectedIndex].dataset.precio);
    const cantidad = parseInt(document.getElementById('cantidadVenta').value);

    const subtotal = productoPrecio * cantidad;

    const productosTable = document.getElementById('productosVentaTable').getElementsByTagName('tbody')[0];
    const row = productosTable.insertRow();
    row.dataset.productoId = productoId;
    row.innerHTML = `
        <td>${productoNombre}</td>
        <td>${cantidad}</td>
        <td>${productoPrecio.toFixed(2)}</td>
        <td>${subtotal.toFixed(2)}</td>
        <td><button type="button" onclick="eliminarProducto(this)">Eliminar</button></td>
    `;

    actualizarTotal();
}

function eliminarProducto(button) {
    const row = button.closest('tr');
    row.remove();
    actualizarTotal();
}

function actualizarTotal() {
    const productosTable = document.getElementById('productosVentaTable').getElementsByTagName('tbody')[0];
    let total = 0;
    for (const row of productosTable.rows) {
        total += parseFloat(row.cells[3].textContent);
    }
    document.getElementById('totalVenta').textContent = total.toFixed(2);
}

function registrarVenta() {
    const productosTable = document.getElementById('productosVentaTable').getElementsByTagName('tbody')[0];
    const productos = [];
    for (const row of productosTable.rows) {
        productos.push({
            id: row.dataset.productoId,
            cantidad: row.cells[1].textContent
        });
    }

    const data = {
        action: 'registrar_venta',
        productos: productos
    };

    fetch('/cgi-bin/gestion_ventas.pl', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert(data.success);
            cargarVentas();
            productosTable.innerHTML = '';
            actualizarTotal();
        } else {
            alert("Error: " + data.error);
        }
    })
    .catch(error => alert("Error de red: " + error));
}
