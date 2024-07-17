document.addEventListener('DOMContentLoaded', function() {
    cargarProductos();

    document.getElementById('productoForm').addEventListener('submit', function(event) {
        event.preventDefault();
        if (validarFormulario()) {
            agregarProducto();
        }
    });
});

function validarFormulario() {
    const nombre = document.getElementById('nombreProducto').value;
    const precio = parseFloat(document.getElementById('precioProducto').value);
    const cantidad = parseInt(document.getElementById('cantidadProducto').value);

    if (!nombre) {
        alert("El nombre del producto no puede estar vacío.");
        return false;
    }

    if (isNaN(precio) || precio <= 0) {
        alert("El precio debe ser un número positivo.");
        return false;
    }

    if (isNaN(cantidad) || cantidad < 0) {
        alert("La cantidad debe ser un número entero no negativo.");
        return false;
    }

    return true;
}

function agregarProducto() {
    const formData = new FormData(document.getElementById('productoForm'));
    formData.append('action', 'agregar_producto');  // Asegúrate de que la acción se está enviando
    fetch('../../cgi-bin/gestion_kardex.pl?action=listar_movimientos', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert(data.success);
            cargarProductos();
        } else {
            alert("Error: " + data.error);
        }
    })
    .catch(error => alert("Error de red: " + error));
}

function cargarProductos() {
    fetch('/cgi-bin/gestion_productos.pl?action=listar_productos')
        .then(response => response.json())
        .then(data => {
            const productosTable = document.getElementById('productosTable').getElementsByTagName('tbody')[0];
            productosTable.innerHTML = '';
            data.forEach(producto => {
                const row = productosTable.insertRow();
                row.innerHTML = `
                    <td>${producto.nombre}</td>
                    <td>${producto.precio}</td>
                    <td>${producto.cantidad}</td>
                    <td>
                        <button onclick="eliminarProducto(${producto.id})">Eliminar</button>
                        <button onclick="mostrarEditarProducto(${producto.id}, '${producto.nombre}', ${producto.precio}, ${producto.cantidad})">Editar</button>
                    </td>
                `;
            });
        });
}

function eliminarProducto(id) {
    fetch(`/cgi-bin/gestion_productos.pl?action=eliminar_producto&id=${id}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert(data.success);
                cargarProductos();
            } else {
                alert("Error: " + data.error);
            }
        })
        .catch(error => alert("Error de red: " + error));
}

function mostrarEditarProducto(id, nombre, precio, cantidad) {
    document.getElementById('nombreProducto').value = nombre;
    document.getElementById('precioProducto').value = precio;
    document.getElementById('cantidadProducto').value = cantidad;
    document.getElementById('productoForm').onsubmit = function(event) {
        event.preventDefault();
        actualizarProducto(id);
    };
}

function actualizarProducto(id) {
    const formData = new FormData(document.getElementById('productoForm'));
    formData.append('action', 'actualizar_producto');
    formData.append('id', id);
    fetch('/cgi-bin/gestion_productos.pl', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert(data.success);
            cargarProductos();
            document.getElementById('productoForm').reset();
            document.getElementById('productoForm').onsubmit = function(event) {
                event.preventDefault();
                agregarProducto();
            };
        } else {
            alert("Error: " + data.error);
        }
    })
    .catch(error => alert("Error de red: " + error));
}
