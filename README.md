# BetweenPages

BetweenPages es una plataforma de seguimiento de lectura que permite a los usuarios gestionar y organizar sus libros, mangas y fanfictions.

## 📋 Descripción

Este proyecto es un TFC (Trabajo Final de Ciclo) que proporciona una API REST para gestionar:
- **Catálogo de contenido**: Libros, mangas y fanfictions
- **Journal de lectura**: Seguimiento personal del progreso de lectura
- **Listas personalizadas**: Organización de contenido en listas
- **Gestión de usuarios**: Registro, autenticación y perfiles

## 🛠️ Tecnologías

### Backend
- **Java 21**
- **Spring Boot 3.3.1**
- **Spring Security** - Autenticación y autorización
- **Spring Data JPA** - Persistencia de datos
- **PostgreSQL** - Base de datos
- **JWT** - Autenticación basada en tokens
- **SpringDoc OpenAPI** - Documentación de la API
- **Lombok** - Reducción de código boilerplate
- **Maven** - Gestión de dependencias

## 📁 Estructura del Proyecto

```
backend/
├── src/
│   ├── main/
│   │   ├── java/com/calonuria/backend/
│   │   │   ├── config/          # Configuración de Spring
│   │   │   ├── controller/      # Controladores REST
│   │   │   │   ├── catalog/     # Endpoints de catálogo
│   │   │   │   ├── journal/     # Endpoints de journal
│   │   │   │   ├── list/        # Endpoints de listas
│   │   │   │   └── user/        # Endpoints de usuarios
│   │   │   ├── dto/             # Data Transfer Objects
│   │   │   ├── model/           # Entidades JPA
│   │   │   ├── repository/      # Repositorios
│   │   │   ├── service/         # Lógica de negocio
│   │   │   └── security/        # Configuración de seguridad
│   │   └── resources/
│   │       └── application.yaml # Configuración de la aplicación
│   └── test/                    # Tests
├── pom.xml
└── mvnw
```

## 🚀 Instalación y Configuración

### Prerrequisitos
- Java 21 o superior
- PostgreSQL 
- Maven (incluido con el proyecto mediante Maven Wrapper)

### Configuración de Base de Datos

1. Crear una base de datos PostgreSQL:
```bash
createdb between_pages
```

2. Configurar las credenciales en `backend/src/main/resources/application.yaml`:
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/between_pages
    username: tu_usuario
    password: tu_contraseña
```

### Ejecutar la Aplicación

```bash
cd backend
./mvnw spring-boot:run
```

La aplicación estará disponible en `http://localhost:8080`

## 📚 API Documentation

Una vez que la aplicación esté ejecutándose, puedes acceder a la documentación interactiva de la API en:

```
http://localhost:8080/swagger-ui.html
```

## 🔐 Autenticación

La API utiliza JWT (JSON Web Tokens) para la autenticación. Los endpoints principales de autenticación son:

- `POST /api/auth/registro` - Registro de nuevos usuarios
- `POST /api/auth/login` - Inicio de sesión

## 📝 Endpoints Principales

### Catálogo
- **Libros**: `/api/libros`
- **Mangas**: `/api/mangas`
- **Fanfictions**: `/api/fanfictions`

### Journal (Seguimiento de Lectura)
- **Journal de Libros**: `/api/journal/libros`
- **Journal de Mangas**: `/api/journal/mangas`
- **Journal de Fanfics**: `/api/journal/fanfics`

### Listas
- **Gestión de Listas**: `/api/listas`

### Usuarios
- **Autenticación**: `/api/auth`
- **Perfil**: `/api/usuarios`

## 👨‍💻 Autor

**Nuria Calo** - Proyecto TFC
