# Reglas de frontend — Angular 20+

> El frontend vive en `frontend/`. Las fuentes Angular están en `frontend/src/`.
> Aplica solo si el proyecto usa Angular 20+. Para React usa `frontend-react.md`.

## Modernización obligatoria en código nuevo

- Standalone components. No crees `NgModule` en código nuevo.
- `inject()` en lugar de constructor injection.
- `input()` / `output()` signals-based en lugar de `@Input()` / `@Output()`.
- Signals: `signal()`, `computed()`, `effect()`. `toSignal()` para convertir observables.
- `AsyncPipe` o `toSignal()` para observables. Sin suscripciones manuales sin `takeUntilDestroyed()`.
- Interceptores con `HttpInterceptorFn` (funcional). Sin clases interceptoras en código nuevo.
- `provideRouter`, `provideHttpClient`, `provideAnimationsAsync` en `app.config.ts`.

## HTTP

- `HttpClient` solo en servicios. Nunca en componentes.
- Interceptores funcionales para tokens y manejo de errores globales.
- Maneja errores HTTP en el servicio con `catchError`. El componente solo muestra el estado de error.

## Formularios

- Reactive Forms para validación compleja o dinámica.
- Template-driven Forms solo para formularios muy simples.
- No mezcles ambos enfoques en el mismo formulario.
- Validadores reutilizables como funciones puras en `frontend/src/app/shared/validators/`.

## Routing

- Lazy loading con `loadComponent` o `loadChildren` en todas las rutas de feature.
- Guards como funciones (`canActivate`, `canMatch`). Sin clases guard en código nuevo.

## Performance

- `@defer` para componentes pesados no críticos al render inicial.
- `@for` requiere `track` obligatorio. Sin `track`, Angular no optimiza la lista.

## TypeScript

- `strict: true` siempre. No uses `any` sin justificación documentada.
- Tipifica respuestas de API con interfaces explícitas.

## Testing Angular (TDD)

Escribe la prueba antes de implementar el componente o servicio.

- Jest + Angular Testing Library.
- Prueba comportamiento visible al usuario: renders, interacciones, outputs.
- No pruebes detalles de implementación interna.
- No hagas snapshot tests de componentes complejos.
- `TestBed` solo cuando sea estrictamente necesario.

## Estructura de carpetas

```
frontend/
  src/
    app/
      core/
        guards/
        interceptors/
        services/          ← Servicios singleton (auth, logging)
      shared/
        components/        ← Componentes reutilizables sin lógica de negocio
        pipes/
        directives/
        validators/
      features/
        nombre-feature/
          components/
          services/
          models/
          pages/
          nombre-feature.routes.ts
      app.config.ts
      app.routes.ts
  angular.json
  package.json
```

## Verificación antes de entregar

- [ ] Prueba escrita antes de la implementación (TDD)
- [ ] `ng build` sin errores
- [ ] `ng test --watch=false` todos en verde
- [ ] `ng lint` sin errores
- [ ] Sin `any` sin justificación
- [ ] Sin `@Input()` / `@Output()` en componentes nuevos
- [ ] Sin suscripciones manuales sin `takeUntilDestroyed()`
- [ ] Sin `console.log` en código de producción
