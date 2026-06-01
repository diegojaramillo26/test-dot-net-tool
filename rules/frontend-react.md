# Reglas de frontend — React 18+

> El frontend vive en `frontend/`. Las fuentes React están en `frontend/src/`.
> Aplica solo si el proyecto usa React 18+. Para Angular usa `frontend-angular.md`.

## Componentes

- Functional components con hooks únicamente. Sin class components en código nuevo.
- Tipifica props con `interface NombreComponenteProps`. Sin `React.FC<>` como wrapper.
- Divide componentes que superen 150 líneas o tengan más de una responsabilidad visual.
- Nombra el archivo y la función con `PascalCase`. Exporta con nombre.
- No hagas llamadas HTTP directamente en componentes.

## Hooks

- `useState` para estado local simple.
- `useReducer` para estado con lógica de transición compleja.
- `useMemo` para valores costosos. No lo uses para optimizaciones prematuras.
- `useCallback` para funciones pasadas como props a hijos memoizados con `React.memo`.
- **No uses `useEffect` para derivar estado.** Calcula en el render o usa `useMemo`.
- Custom hooks con prefijo `use`. Una responsabilidad por hook.

## TanStack Query (estado del servidor)

- `useQuery` con `queryKey` explícito y estable para fetching.
- `useMutation` para escritura. Invalida cache después del éxito.
- Centraliza funciones de fetching en `frontend/src/services/api/`.
- El estado del servidor (datos de API) no va en el store global.

## Estado global del cliente

Usa Zustand o Redux Toolkit — uno por proyecto, nunca ambos.

- **Zustand:** un store por dominio funcional. `create<TStore>()` con tipado.
- **RTK:** `createSlice` y `createAsyncThunk`. Sin reducers manuales.
- El store es para estado del cliente (UI, usuario autenticado), no datos de API.

## TypeScript

- `strict: true`. Sin `any` sin justificación documentada.
- Tipifica respuestas de API con interfaces explícitas.
- `unknown` para tipos realmente desconocidos. Aplica type narrowing antes de usar.

## Testing React (TDD)

Escribe la prueba antes de implementar el componente o hook.

- Jest + React Testing Library + MSW para mocks de red.
- `renderHook` para pruebas de hooks.
- Prueba comportamiento visible al usuario. No pruebes internals.
- MSW para interceptar HTTP. Sin mocks manuales de `fetch` o `axios`.
- Sin snapshot tests de componentes complejos.

## Estructura de carpetas

```
frontend/
  src/
    components/         ← UI reutilizable sin lógica de negocio
    features/
      nombre-feature/
        components/
        hooks/
        types/
        index.ts
    hooks/              ← Hooks globales reutilizables
    services/
      api/              ← Funciones de fetching y clientes de API
    stores/             ← Stores globales (Zustand / RTK)
    types/              ← Interfaces y tipos globales
    utils/              ← Utilidades puras
    pages/              ← Componentes de página / rutas
  package.json
  tsconfig.json
```

## Verificación antes de entregar

- [ ] Prueba escrita antes de la implementación (TDD)
- [ ] `npm run build` sin errores de TypeScript
- [ ] `npm test -- --watchAll=false` todos en verde
- [ ] `npm run lint` sin errores
- [ ] Sin `any` sin justificación
- [ ] Sin `useEffect` para derivar estado
- [ ] Sin llamadas HTTP en componentes
- [ ] Sin `console.log` en código de producción
- [ ] Sin datos sensibles en stores accesibles por DevTools
