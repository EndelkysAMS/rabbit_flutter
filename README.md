# Rabbit(Flutter)

Aplicación móvil de transporte diseñada específicamente para la región de Betijoque, orientada a optimizar y gestionar las líneas de mototaxis y mejorar la movilidad local de la parroquia.

Este proyecto está desarrollado utilizando el framework Flutter, enfocado en ofrecer una experiencia multiplataforma rápida y fluida.

---

## Enlaces del Proyecto

* **Diseño en Figma:** [Ver Prototipo en Figma](https://www.figma.com/design/TycvS7GzehRc8mBCVVnrHx/Rabbit?node-id=29-7&t=xVEEkELL8Es47VaB-1)
* **Repositorio Backend (Django):** [Rabbit Backend](https://github.com/EndelkysAMS/rabbit_backend)
* **Repositorio Frontend (Flutter):** [Rabbit Flutter](https://github.com/EndelkysAMS/rabbit_flutter)

---

## Características Principales

* **Gestión de Líneas de Transporte:** Visualización, organización y selección de las distintas líneas de mototaxis activas en la zona de Betijoque.
* **Autenticación:** Sistema de registro e inicio de sesión adaptado para diferentes tipos de usuarios (pasajeros y conductores).
* **Interfaz Dinámica:** Incorporación de animaciones avanzadas y selectores de interfaz para una experiencia de usuario optimizada e intuitiva.
* **Integración de API:** Conexión y sincronización de datos con el backend desarrollado en Django y base de datos MySQL.

---

## Tecnologías y Dependencias Clave

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Animaciones:** Lottie para transiciones y elementos visuales de carga.
* **Componentes UI:** Toggle Switch y otros widgets personalizados para navegación rápida.

---

## Estructura General del Proyecto

El código fuente principal se encuentra en el directorio `lib/`, organizado de manera modular:

```text
lib/
├── assets/          # Recursos estáticos (imágenes, fuentes, animaciones Lottie)
├── components/      # Componentes de interfaz de usuario reutilizables (botones, inputs, etc.)
├── models/          # Modelos de datos estructurados para la integración con la API
├── screens/         # Pantallas principales y flujos de navegación
├── services/        # Lógica de conexión, peticiones HTTP al backend de Django
└── main.dart        # Punto de entrada principal de la aplicación móvil
```

---

## Despliegue y Ejecución Local

Para clonar, compilar y ejecutar este proyecto de forma local, sigue estos pasos:

### 1. Requisitos Previos
* Tener instalado [Flutter SDK](https://docs.flutter.dev/get-started/install).
* Contar con un IDE compatible (Cursor, VS Code, Android Studio).
* Tener un emulador de Android/iOS configurado o un dispositivo físico con depuración USB habilitada.

### 2. Clonar el Repositorio
```bash
git clone https://github.com/EndelkysAMS/rabbit_flutter.git
cd rabbit_flutter
```

### 3. Instalar Dependencias
Descarga e instala todos los paquetes y dependencias requeridas:
```bash
flutter pub get
```

### 4. Sincronización con el Backend
Asegúrate de que el servidor backend (Django) esté en funcionamiento en tu entorno local o remoto. Actualiza la URL base de la API dentro del directorio `services/` o en tu archivo de variables de entorno para que apunte correctamente a la dirección de tu backend.

### 5. Ejecutar la Aplicación
Inicia el entorno de pruebas en tu emulador o dispositivo:
```bash
flutter run
```