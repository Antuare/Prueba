# Prueba — SDF Volumétrico 3D Implícito (Odin + Q32.32)

App de demostración de un **Signed Distance Field volumétrico 3D implícito** escrito completamente en **Odin** usando únicamente aritmética de punto fijo **Q32.32** (`i64`).  
**Cero floats** en el cálculo del SDF y del mapa.

## Características

- Coordenadas y distancias en **Q32.32** (32 bits enteros + 32 bits fraccionarios)
- SDF implícito puro (esfera, caja, plano, unión, intersección, sustracción)
- Mapa 3D estilo **RPG** con terreno procedural + **agua**
- Tabla de **Elements** (Tierra, Agua, Aire, Fuego, Metal…)
- Sistema de **Materials** derivados de los elementos (Stone, Dirt, Water, Sand, Wood…)
- Visualización en tiempo real con **vendor:raylib** (raymarching del SDF)

## Requisitos

- [Odin](https://odin-lang.org/) (cualquier nightly reciente)
- El paquete `vendor:raylib` ya viene incluido con Odin

## Cómo compilar y ejecutar

```bash
odin run . -out:prueba
```

o

```bash
odin build . -out:prueba -o:speed
./prueba
```

## Controles

- **WASD** / flechas : mover cámara
- **Rueda del ratón** : zoom
- **Espacio** : subir
- **Ctrl / C** : bajar
- **Esc** : salir

## Estructura del proyecto

```
Prueba/
├── main.odin          # Punto de entrada + raylib + raymarching
├── fixed.odin         # Tipos y operaciones Q32.32
├── sdf.odin           # Primitivas SDF + operaciones CSG (solo i64)
├── elements.odin      # Tabla de Elements
├── materials.odin     # Materiales y propiedades
├── world.odin         # Mapa RPG (terreno + agua)
└── README.md
```

## Filosofía

Todo el núcleo matemático del mundo se mantiene en **punto fijo** para demostrar que se puede hacer un SDF volumétrico completo sin un solo `f32`/`f64` en el cálculo de distancias.
