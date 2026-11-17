# TaskFlow

Aplicación Flutter para organizar tareas personales de estudio y trabajo.

## Problema y usuario objetivo

Un estudiante que combina clases y actividades personales necesita registrar sus pendientes, reconocer su prioridad y consultar su avance sin depender de notas dispersas. El usuario objetivo es un estudiante que administra sus propias tareas desde un teléfono Android. En la demostración local se usa el usuario `1` (Roberto Mero); no existe autenticación todavía.

## Alcance viable en ocho semanas

El producto mínimo permitirá listar, consultar, crear, editar y eliminar tareas propias, con título, descripción, prioridad y estado. Tendrá tres pantallas, validación de formularios, una API JSON y persistencia en el servidor. Una identidad de demostración fija permite terminar el flujo individual; el servidor deberá restringir el acceso a esa identidad configurada y no confiar en un `userId` enviado por el cliente. El inicio de sesión multiusuario se deja para una etapa posterior.

Fuera de alcance: equipos, tareas compartidas, chat, adjuntos, notificaciones, calendarios, sincronización sin conexión y estadísticas históricas.

| Semana | Entrega verificable |
| --- | --- |
| 1 | Problema, alcance, historias, modelo y contrato JSON |
| 2 | Listado y detalle con datos locales y navegación por id |
| 3 | Formulario de creación y validación |
| 4 | Edición, cambio de estado y eliminación con confirmación |
| 5 | API y persistencia: listar, detalle y crear |
| 6 | Integración de actualizar y eliminar; estados de carga y error |
| 7 | Pruebas del flujo completo y revisión de usabilidad en Android |
| 8 | Correcciones, evidencia y demostración final |

## Cinco historias de usuario y requisitos funcionales

| ID | Historia | Criterio de aceptación comprobable |
| --- | --- | --- |
| HU1 / RF1 | Como estudiante, quiero ver mis tareas para identificar mis pendientes. | Con cinco tareas del usuario, el listado muestra sus títulos, prioridades y estados; con cero muestra un mensaje de lista vacía. |
| HU2 / RF2 | Como estudiante, quiero consultar una tarea para leer toda su descripción. | Al tocar una tarjeta se abre `/task/:id` con los datos de esa tarea; Volver regresa al listado y un id inexistente muestra un mensaje. |
| HU3 / RF3 | Como estudiante, quiero crear una tarea para organizar mi trabajo. | Un título no vacío, descripción y prioridad válida permiten guardar una tarea pendiente del usuario actual; aparece una sola vez en el listado. Un título vacío impide guardar. |
| HU4 / RF4 | Como estudiante, quiero actualizar una tarea para reflejar cambios en mi trabajo. | Al guardar título, descripción, prioridad o estado, listado y detalle reflejan los cambios sin alterar el id ni el usuario; cancelar conserva los datos anteriores. |
| HU5 / RF5 | Como estudiante, quiero eliminar una tarea que ya no necesito para mantener mi lista ordenada. | Desde el detalle se solicita confirmación; confirmar elimina la tarea y vuelve al listado; cancelar la conserva. |

Revisión de las historias: cada una identifica un actor, una acción y un beneficio; sus criterios permiten comprobar éxito y alternativas. HU4 se implementará mediante subtareas de formulario y cambio de estado. La revisión cruzada con un compañero o docente queda pendiente: no se presenta como realizada.

## Requisitos no funcionales

- **Usabilidad:** textos y errores en español, controles con etiqueta, regreso visible, formularios desplazables y eliminación confirmada. Revisar en Android a 360 × 640 píxeles lógicos y con texto ampliado para detectar desbordamientos.
- **Rendimiento:** objetivo de presentar 100 tareas locales en menos de un segundo tras cargar los datos, medido en modo profile en el dispositivo de prueba. No bloquear la interfaz durante peticiones; mostrar carga y permitir reintentar errores. Esta medición está pendiente.
- **Mantenibilidad:** modelo Dart independiente de widgets, conversión JSON centralizada, pruebas de modelo y navegación, y `flutter analyze` sin incidencias.
- **Integridad:** ids y usuario positivos, título no vacío, prioridad Alta/Media/Baja y estado booleano. La API futura validará datos y pertenencia también en el servidor.

## Modelo principal: Task

Implementación: `lib/features/tasks/domain/task.dart`. El modelo describe información del dominio, no colores, iconos, rutas o widgets.

| Propiedad Dart / JSON | Tipo | Significado |
| --- | --- | --- |
| `id` | `int` | Identificador positivo, único en la colección; el servidor lo asignará al crear. |
| `title` | `String` | Título no vacío después de quitar espacios. |
| `description` | `String` | Descripción completa; admite cadena vacía. |
| `priority` | `String` | Uno de `Alta`, `Media`, `Baja`. |
| `isCompleted` | `bool` | `false`: pendiente; `true`: completada. |
| `userId` | `int` | Identificador positivo del propietario. Un usuario puede tener muchas tareas. |

`Task.fromJson` exige los seis campos con sus tipos y valores válidos y lanza `FormatException` ante datos incompletos o inválidos. `toJson` produce el objeto intercambiable. `copyWith` permite modificar los campos editables y conserva identidad y propietario. El constructor `const` se usa con datos locales conocidos; la validación de entrada JSON se hace en la fábrica. La unicidad del id corresponde a la colección o al servidor.

JSON es texto: un objeto usa llaves y una lista usa corchetes. Dart convierte entre texto y mapas/listas mediante `jsonDecode` y `jsonEncode` de `dart:convert`.

```json
{
  "id": 1,
  "title": "Leer documentación",
  "description": "Revisar ListView.builder",
  "priority": "Alta",
  "isCompleted": false,
  "userId": 1
}
```

```dart
final task = Task.fromJson(jsonDecode(jsonText) as Map<String, dynamic>);
final jsonTextAgain = jsonEncode(task.toJson());
final tasks = (jsonDecode(listJsonText) as List<dynamic>)
    .map((item) => Task.fromJson(item as Map<String, dynamic>))
    .toList();
```

Estos fragmentos requieren importar `dart:convert` y el modelo. `demoTasks` en `lib/features/tasks/data/demo_tasks.dart` contiene cinco objetos locales con ids distintos, las tres prioridades y ambos estados, asociados a `demoUserId`.

## Boceto de tres pantallas

Los bocetos especifican el producto final. Listado y detalle ya existen; formulario, edición completa y eliminación están previstos.

```text
1. LISTADO · /                    2. DETALLE · /task/:id
+----------------------------+   +----------------------------+
| Mis tareas                 |   | < Detalle de tarea         |
| Hola, Roberto              |   | Leer documentación         |
| Pendientes: 4              |   | Revisar ListView.builder   |
| [+ Agregar]                |   | Prioridad: Alta            |
| Leer documentación    >    |   | Estado: pendiente          |
| Alta · Pendiente           |   | [Marcar como completada]   |
| Diseñar la pantalla   >    |   | [Editar] [Eliminar]        |
| Media · Pendiente          |   | [Volver al listado]        |
+----------------------------+   +----------------------------+

3. FORMULARIO · /task/new o /task/:id/edit (rutas propuestas)
+----------------------------------------+
| < Crear / Editar tarea                  |
| Título:      [______________________]  |
| Descripción: [______________________]  |
| Prioridad:   [Alta / Media / Baja   v]  |
| Estado:      [Pendiente / Completada]   |
| Mensaje de validación junto al campo   |
| [Cancelar]                  [Guardar]  |
+----------------------------------------+
```

Flujo: Listado → Detalle → Listado; Listado → Crear → Listado; Detalle → Editar → Detalle. En creación el estado inicial será pendiente. La ruta estática `/task/new` deberá declararse antes de `/task/:id` al implementar el formulario para evitar interpretarla como un id.

## Endpoints requeridos (contrato propuesto, sin backend implementado)

Base propuesta: `/api`. Formato de solicitudes y respuestas: `application/json`, salvo `204` sin cuerpo. El servidor determinará el usuario de la sesión de demostración; nunca permitirá cambiar el propietario mediante POST o PATCH.

| Acción | Método y endpoint | Entrada | Respuesta de éxito |
| --- | --- | --- | --- |
| Listar | `GET /api/tasks` | Sin cuerpo | `200`: lista de objetos Task del usuario actual (`[]` si no hay). |
| Detalle | `GET /api/tasks/{id}` | Id positivo en ruta | `200`: objeto Task completo. |
| Crear | `POST /api/tasks` | `title`, `description`, `priority`; estado inicial pendiente | `201`: Task completo con id y userId asignados por el servidor. |
| Actualizar | `PATCH /api/tasks/{id}` | Uno o más de `title`, `description`, `priority`, `isCompleted` | `200`: Task completo actualizado. |
| Eliminar | `DELETE /api/tasks/{id}` | Id positivo en ruta | `204`: sin cuerpo. |

Ejemplo de creación:

```json
{"title":"Preparar entrega","description":"Revisar el README","priority":"Media"}
```

Ejemplo de actualización:

```json
{"isCompleted":true}
```

Errores previstos: `400` para JSON mal formado o id no numérico; `422` para campos inválidos, campos no permitidos o PATCH vacío; `404` para tarea inexistente o ajena; `500` para fallo del servidor. Formato: `{"error":{"code":"validation_error","message":"El título es obligatorio"}}`. La lista y el detalle siempre devuelven los seis campos del modelo. Las URLs de API son distintas de las rutas de navegación Flutter.

## Estado actual y verificación

Implementado: cinco tareas locales, listado y detalle por id con GoRouter, adición de una tarea de ejemplo, cambio de estado, propietario local, modelo separado y conversión JSON. La información vive en memoria y se reinicia al cerrar la app. El botón Agregar aún genera un título de ejemplo; no abre un formulario. El contador «Hoy» es una demostración, no una métrica histórica: el modelo no contiene fechas.

Pendiente: formulario, edición de textos/prioridad desde la interfaz, eliminación, estados de carga/error y backend persistente. Los endpoints anteriores son requisitos, no servicios disponibles.

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

`test/task_test.dart` verifica la conversión objeto → texto JSON → objeto, listas JSON, datos inválidos, propiedad de las tareas y conservación de identidad al actualizar. `test/widget_test.dart` comprueba listado → detalle → regreso, cambio de estado y rutas inválidas; incluye las capturas existentes de `test/evidence/`.


## Arquitectura MVVM por funcionalidad

```text
lib/
  main.dart                         # Punto de entrada
  app/
    task_flow_app.dart               # Inyección con Provider y ciclo de vida
    app_router.dart                  # Rutas / y /task/:id
  core/theme/app_theme.dart          # Tema compartido
  features/tasks/
    domain/task.dart                 # Entidad y contrato JSON
    data/
      demo_tasks.dart                # Cinco tareas y usuario de demostración
      task_repository.dart           # Contrato observable, fuente de verdad
      local_task_repository.dart     # Identidad, estado y conversión JSON
      task_service.dart              # Contrato de acceso a la fuente local
      local_task_service.dart        # Almacenamiento JSON en memoria
    presentation/
      tasks_view_model.dart          # Estado derivado y acciones de pantalla
      task_list_view.dart            # Listado y eventos visuales
      task_detail_view.dart          # Detalle, navegación y eventos
      widgets/task_card.dart         # Tarjeta reutilizable
```

Recorrido de una acción: **View → TasksViewModel → TaskRepository → TaskService**. Por ejemplo, al marcar una tarea, la View invoca `toggleTask(id)`, el ViewModel busca la tarea del usuario actual y solicita `setCompleted`, el Repository construye una nueva lista y la guarda mediante el Service. Solo después de guardar publica el estado y notifica; el ViewModel propaga la notificación y Provider reconstruye listado y detalle.

- **View:** muestra los datos y captura eventos con `context.watch` y `context.read`. Conserva navegación, estilos y SnackBars; no modifica listas ni accede a servicios.
- **ViewModel:** expone tareas, contadores, meta diaria y acciones de agregar/completar/reabrir. Depende del contrato Repository, no dibuja widgets ni contiene `BuildContext`. Filtra los datos por el usuario de la demostración.
- **Repository:** es la fuente de verdad de la aplicación. Expone listas inmutables, asigna ids locales, transforma JSON en `Task`, guarda antes de notificar y oculta la implementación del Service.
- **Service:** conoce la fuente concreta. En esta sesión es local, síncrona y en memoria; devuelve copias de mapas JSON para evitar modificaciones externas. No se hacen peticiones HTTP. Al integrar la API propuesta, un Service remoto manejará métodos HTTP, endpoints, códigos y errores; los contratos pasarán a `Future` y el ViewModel incorporará carga/error. Esa integración sigue pendiente.
- **Provider:** `MultiProvider` crea el Service, el Repository y un ViewModel compartido sobre las rutas. `ChangeNotifierProvider` libera Repository y ViewModel al desmontar la app; el ViewModel elimina su listener. El router pertenece a la instancia de la app y también se libera. No quedan listas de tareas ni routers globales mutables.

Una pantalla no debe hacer HTTP directamente: mezclar transporte con widgets acopla el diseño a los endpoints, duplica carga y errores y dificulta probar reglas sin red. La separación permite sustituir el Service en pruebas y conservar las Views cuando cambie el origen de datos. El servicio local no implementa ni simula una API HTTP real.

### Evidencia de la reorganización

Las pruebas visuales existentes comparan listado y detalle contra las mismas capturas, sin regenerarlas. Las pruebas de navegación conservan agregar, completar, reabrir y regresar. `test/tasks_architecture_test.dart` verifica el recorrido completo entre capas, notificaciones compartidas, aislamiento de usuario e instancias, listas inmutables, fallo de guardado y liberación de listeners. Las pruebas JSON siguen cubriendo el modelo en su nueva ubicación.

```sh
flutter analyze
flutter test
flutter build apk --debug
```

El comportamiento visible sigue siendo el de la demostración local. No hay cambios visuales que requieran Hot Reload; después de mover archivos e introducir la raíz de Provider, una sesión de desarrollo abierta debe reiniciarse con Hot Restart.
