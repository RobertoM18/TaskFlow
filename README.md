# TaskFlow

Aplicación Flutter para organizar tareas personales de estudio y trabajo.

**Versión actual:** consulta por defecto las tareas remotas de JSONPlaceholder del usuario **2**. Las cinco tareas académicas del usuario 1 se conservan en el modo local. Consulta la sección «API de tareas» para ejecutar ambos modos y revisar la evidencia.

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
| `priority` | `String` | `Alta`, `Media`, `Baja` o el valor explícito `Sin prioridad (API)` al faltar en el servidor. |
| `isCompleted` | `bool` | `false`: pendiente; `true`: completada. |
| `userId` | `int` | Identificador positivo del propietario. Un usuario puede tener muchas tareas. |

`Task.fromJson` valida id, título, usuario y estado; admite `isCompleted` local o `completed` remoto. Si faltan descripción o prioridad (o llegan como null), utiliza `Sin descripción (API)` y `Sin prioridad (API)`. Tipos obligatorios incorrectos y valores inválidos producen `FormatException`. `toJson` produce el objeto intercambiable. `copyWith` permite modificar los campos editables y conserva identidad y propietario. El constructor `const` se usa con datos locales conocidos; la validación de entrada JSON se hace en la fábrica. La unicidad del id corresponde a la colección o al servidor.

JSON es texto: un objeto usa llaves y una lista usa corchetes. Dart convierte entre texto y mapas/listas mediante `jsonDecode` y `jsonEncode` de `dart:convert`.

```json
{
  "id": 1,
  "title": "Preparar exposición de TaskFlow",
  "description": "Organizar las diapositivas y ensayar la explicación del proyecto.",
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

Implementado: consulta remota asíncrona con Dio, carga/error/reintento/lista vacía, listado y detalle por id, cambio de estado en memoria y modelo JSON compatible con ambos orígenes. Como respaldo se conservan cinco tareas locales y la adición de una tarea de ejemplo en modo local. La información vive en memoria y se reinicia al cerrar la app. En modo local, Agregar genera un título de ejemplo; no abre un formulario. En modo remoto está deshabilitado porque esta sesión solo consulta y cambia estados en memoria. El contador «Hoy» es una demostración, no una métrica histórica: el modelo no contiene fechas.

Pendiente: formulario, edición de textos/prioridad desde la interfaz, eliminación y backend persistente. Los endpoints CRUD de `/api/tasks` anteriores son requisitos futuros; la consulta de práctica actual usa `/todos`.

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
- **Service:** conoce la fuente concreta. En el modo local es síncrona y en memoria; devuelve copias de mapas JSON para evitar modificaciones externas. El modo remoto usa `TaskApiService` con Dio; el contrato Repository ya expone `Future<List<Task>> getTasks()` y el ViewModel maneja carga/error. El contrato local de almacenamiento JSON continúa separado y síncrono.
- **Provider:** `MultiProvider` crea el Service, el Repository y un ViewModel compartido sobre las rutas. `ChangeNotifierProvider` libera Repository y ViewModel al desmontar la app; el ViewModel elimina su listener. El router pertenece a la instancia de la app y también se libera. No quedan listas de tareas ni routers globales mutables.

Una pantalla no debe hacer HTTP directamente: mezclar transporte con widgets acopla el diseño a los endpoints, duplica carga y errores y dificulta probar reglas sin red. La separación permite sustituir el Service en pruebas y conservar las Views cuando cambie el origen de datos. El servicio local no implementa ni simula una API HTTP real.

### Evidencia de la reorganización

La reorganización MVVM se verificó contra las capturas originales. En el avance de personalización se actualizaron las capturas para reflejar las tareas académicas y los campos de identificador y usuario visibles en el detalle. Las pruebas de navegación conservan agregar, completar, reabrir y regresar. `test/tasks_architecture_test.dart` verifica el recorrido completo entre capas, notificaciones compartidas, aislamiento de usuario e instancias, listas inmutables, fallo de guardado y liberación de listeners. Las pruebas JSON siguen cubriendo el modelo en su nueva ubicación.

```sh
flutter analyze
flutter test
flutter build apk --debug
```

El comportamiento sigue siendo el de la demostración local. Después de mover archivos e introducir la raíz de Provider, una sesión de desarrollo abierta debe reiniciarse con Hot Restart. Para recargar las tareas iniciales personalizadas en una sesión ya abierta también se necesita Hot Restart, porque el Repository ya conserva su estado en memoria.


## Personalización y revisión del laboratorio de modelado

El usuario de prueba es Roberto Mero (`userId: 1`), estudiante que prepara las entregas de su aplicación móvil. Estas cinco tareas son ejemplos académicos adaptados al proyecto, no una afirmación sobre actividades reales realizadas. Sustituyen las tareas genéricas del codelab y conservan ids únicos.

| Id | Tarea | Descripción | Prioridad | Estado | Usuario |
| --- | --- | --- | --- | --- | --- |
| 1 | Preparar exposición de TaskFlow | Organizar las diapositivas y ensayar la explicación del proyecto. | Alta | Pendiente | 1 |
| 2 | Practicar navegación por rutas | Abrir las cinco tareas por su id y regresar al listado. | Media | Pendiente | 1 |
| 3 | Documentar el modelo de tareas | Describir los seis campos de Task y un ejemplo JSON en el README. | Baja | Completada | 1 |
| 4 | Repasar arquitectura MVVM | Explicar el recorrido desde la View hasta el Service con un ejemplo. | Alta | Pendiente | 1 |
| 5 | Validar TaskFlow en el teléfono | Probar el listado, el detalle y el cambio de estado en Android. | Media | Pendiente | 1 |

La lista muestra los títulos, descripciones, prioridades y un icono de estado. El detalle permite comprobar los seis datos: título, descripción, prioridad, estado, identificador y usuario. El icono y el texto de estado distinguen una tarea pendiente de una completada.

El modelo permanece en `lib/features/tasks/domain/task.dart`, ya que el proyecto avanzó a MVVM. No se duplica en `lib/task.dart` ni se reemplaza `main.dart` con la versión monolítica del ejemplo. El formulario y los endpoints continúan siendo requisitos futuros.

Evidencia generada mediante las pruebas de widgets, no mediante una captura de un teléfono:

- [Listado con las cinco tareas](test/evidence/listado.png).
- [Detalle con identificador y usuario](test/evidence/detalle.png).

`test/widget_test.dart` recorre las cinco tarjetas, comprueba ruta, descripción, prioridad, estado, identificador y usuario, y verifica el regreso al listado. Las pruebas del modelo comprueban ids distintos y conservación del usuario. El ejercicio guiado `bin/model_demo.dart` se ejecuta con Dart puro y se retira antes del commit, como pide el laboratorio; el modelo compartido no importa Flutter.


## Verificación del laboratorio «Separar TaskFlow en capas con MVVM»

La arquitectura existente cumple esta sesión y conserva las cinco tareas personalizadas y sus seis campos. Se mantienen los nombres y rutas actuales, equivalentes al ejemplo del laboratorio:

| Ejemplo guiado | Implementación en TaskFlow |
| --- | --- |
| `app/taskflow_app.dart` | `app/task_flow_app.dart` y `app/app_router.dart` |
| `core/app_theme.dart` | `core/theme/app_theme.dart` |
| `TaskListScreen` / `TaskDetailScreen` | `TaskListView` / `TaskDetailView` |
| `getTasks()` | Getter inmutable `TaskRepository.tasks` |
| `findTask(id)` | `TasksViewModel.taskById(id)` |
| `toggleCompleted(id)` | `TasksViewModel.toggleTask(id)` |
| `save(task)` | `setCompleted(id, estado)` y `_save` en el repositorio local |

Los objetos de demostración están en `data/demo_tasks.dart`; `LocalTaskService` los entrega a `LocalTaskRepository`. No se duplican ni se trasladan a las Views. Esta separación adicional mantiene todo el acceso a datos dentro de `data`, sin solicitudes HTTP.

Recorrido del botón: `onPressed` obtiene el ViewModel con `context.read`, `toggleTask` invierte el estado, `setCompleted` crea una copia mediante `copyWith`, `_save` guarda en el Service local y el Repository notifica. El ViewModel escucha esa notificación y llama a `notifyListeners`; las Views que usan `context.watch` vuelven a ejecutar `build`. Ambas rutas comparten la única instancia creada sobre el router en `TaskFlowApp`.

Evidencia del avance autónomo (capturas renderizadas por pruebas de widgets):

- [Detalle después de completar la primera tarea](test/evidence/detalle_completada.png).
- [Listado con el icono de completada y contador actualizado](test/evidence/listado_completada.png).

La prueba «Comparte ViewModel y conserva el cambio al reabrir el detalle» comprueba la identidad del ViewModel en ambas pantallas, el texto y botón del detalle, el icono del listado, la conservación del estado al reabrir, el detalle de un segundo id y el regreso al estado inicial al crear una nueva instancia de la app. La persistencia en disco sigue fuera de esta sesión.


## API de tareas

- **URL exacta:** <https://jsonplaceholder.typicode.com/todos?userId=2>
- **Método:** `GET`. **Filtro elegido:** `TaskApiService.userId = 2`, distinto del usuario 1 del ejemplo guiado. El mismo valor se inyecta al ViewModel; no se filtran por error como usuario 1.
- **Fuente:** JSONPlaceholder, datos públicos ficticios para practicar. No hay autenticación ni envío de datos personales.
- **Resultado verificado:** HTTP 200 y 20 tareas del usuario 2 (ids 21–40) el 22 de noviembre de 2026, hora de Ecuador. La evidencia registra el instante en UTC.

| Campo que llega | Campo en TaskFlow | Adaptación |
| --- | --- | --- |
| `id` | `id` | Entero positivo para navegar al detalle |
| `userId` | `userId` | Propietario ficticio, en esta consulta 2 |
| `title` | `title` | Texto del servidor, sin traducir |
| `completed` | `isCompleted` | Booleano; el formato local `isCompleted` también se admite y tiene prioridad |
| No llega `description` | `description` | `Sin descripción (API)`, agregado por TaskFlow |
| No llega `priority` | `priority` | `Sin prioridad (API)`, agregado por TaskFlow |

Los valores por defecto no vienen del servidor ni representan una prioridad real. JSONPlaceholder no cubre todavía el contrato completo del producto final.

### Recorrido y comportamiento

`TaskFlowApp` crea `TaskApiService`, `RemoteTaskRepository` y un único `TasksViewModel` con Provider. La creación del ViewModel llama una vez a `loadTasks()`. El contrato Repository conserva su getter de caché inmutable y añade `Future<List<Task>> getTasks()`; el respaldo local implementa el mismo método asíncrono.

La View nunca llama a Dio. El Service conoce la URL, el filtro, el método GET y los tiempos máximos de conexión y recepción (10 segundos); Dio decodifica el JSON. `Task.fromJson` convierte cada objeto. El Repository actualiza su caché solo después de validar toda la respuesta; el ViewModel recibe la notificación y las Views se reconstruyen con Provider. El Service rechaza respuestas sin lista, filas inválidas, ids duplicados o un usuario distinto del solicitado.

La lista muestra indicador de carga, un mensaje cuando no hay tareas y un error con Reintentar si falla la red. El detalle abierto directamente también espera la carga antes de mostrar los datos o «Tarea no encontrada». No se sustituye una consulta fallida por datos locales sin avisar. Las respuestas tardías no notifican objetos ya liberados.

**Marcar como completada o pendiente solo cambia la copia en memoria.** No se hace POST, PATCH ni DELETE. Volver al listado y reabrir conserva ese cambio durante la sesión; recargar desde la API o reiniciar la app recupera el estado del servidor. Agregar está deshabilitado en modo remoto; su comportamiento de ejemplo se conserva en modo local.

### Ejecutar y comprobar

```sh
flutter pub get
flutter run -d chrome
# Respaldo local: las cinco tareas académicas originales
flutter run -d chrome --dart-define=USE_LOCAL_TASKS=true
flutter analyze
flutter test
# Consulta real explícita: requiere internet y actualiza la evidencia de respuesta
flutter test tool/api_smoke_test.dart
```

El permiso `android.permission.INTERNET` está declarado una sola vez en el manifest principal de Android. Se usa HTTPS. El tema, las rutas y la arquitectura MVVM permanecen separados. Después de añadir Dio y el permiso se requiere reiniciar la ejecución de Flutter.

### Evidencia y pruebas

- [Consola de la consulta real HTTP 200](test/evidence/api_http.txt).
- [Datos públicos recibidos y normalizados como Task](test/evidence/api_tasks.json).
- [Listado remoto](test/evidence/listado_api.png).
- [Detalle remoto con usuario 2 y valores de respaldo](test/evidence/detalle_api.png).

Las capturas se renderizan mediante pruebas de widgets usando la respuesta real guardada; no se presentan como capturas de un teléfono. La petición HTTP real se comprueba separadamente con `tool/api_smoke_test.dart`, que usa el mismo Service y Dio de la app. La suite habitual usa un adaptador HTTP simulado para ser reproducible sin internet.

Las pruebas cubren la URL y el filtro, HTTP no exitoso, timeout, respuesta inválida, lista vacía, reintento, navegación, carga de enlaces directos, cambio local sin otra petición, recuperación del estado remoto al recargar, y liberación durante una petición pendiente. Las pruebas locales y las cinco tareas propias de las sesiones anteriores se mantienen.
