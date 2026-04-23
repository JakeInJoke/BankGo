## Funcion
Actúa como Product Designer. Basado en los requerimientos de BankGo, definido por el Design Sheet (DESIGN.md) dentro de esta carpeta.

## Tema 
Banca personal moderna y segura.

## Contenido
Diseña el flujo de: 
    1. Login (con validación de credenciales, con teclado en pantalla que cambie su distribución de teclas) , 
    2. Dashboard (listado de cuentas con sus saldos y tarjetas disponibles), 
    3. Vista de tarjeta (disponible al tocar el icono de la tarjeta con opción de ver movimientos individuales por tarjeta y opción de apagar tarjeta )
    4. Pago de servicio con tarjetas (disponible al tocar el icono de la tarjeta con opción de pagar servicios)
    5. Detalle de movimientos en general (con paginado, disponible en la barra inferior como Movimientos), 
    6. Transferencia (Revisión/Confirmación, con validación de datos de transferencia y disponibilidad de saldo, la confirmación detona una alerta in app), 
    7. Sistema de alertas in-app.

## Estados Críticos 
Define visualmente cómo se verán los estados de 'Carga', 'Error', 'Lista vacía' y 'Botón de reintento'. Genera una descripción de los wireframes para que un desarrollador pueda implementarlos en [Flutter]

## Detalles
- En los distintos estados deben de aparecer pantallas que hagan referencia al estado en el que pertenecen
- No olvides colocar el botón de reintentar ni los esqueletos del diseño cuando se encuentre en carga o espera
- Si la lista está vacía que muestre el mensaje en pantalla correspondiente al dato que se quiso consultar