Preguntas que el documento ./usage-guide.md

Inclusión y Configuración de Templates

- ¿Cómo incluyo templates de "to be continuous" en mi proyecto GitLab?
- ¿Cuál es la diferencia entre include:component, include:project e include:remote?
- ¿Qué sintaxis debo usar para configurar templates: inputs o variables?
- ¿Cómo configuro un proyecto Maven con SonarQube usando estos templates?
- ¿Puedo usar versiones específicas de los templates o solo "latest"?
- ¿Cómo funciona el versionado semántico de los templates?

Debugging y Troubleshooting

- ¿Cómo activo el modo debug en los jobs?
- ¿Cuál es la diferencia entre $TRACE y CI_DEBUG_TRACE?
- ¿Es seguro usar CI_DEBUG_TRACE en producción?
- ¿Cómo puedo ver logs detallados de los templates?

Gestión de Imágenes Docker

- ¿Cuándo debo usar "latest" vs versiones fijas de imágenes Docker?
- ¿Para qué herramientas es apropiado usar "latest"?
- ¿Para qué herramientas NO debo usar "latest"?
- ¿Cómo sobreescribo las versiones de las imágenes de contenedor?

Secrets y Seguridad

- ¿Cómo gestiono secretos de forma segura en to-be-continuous?
- ¿Qué hago si mi secreto contiene caracteres especiales?
- ¿Cómo uso secretos desde HashiCorp Vault?
- ¿Puedo cargar secretos desde URLs externas?
- ¿Qué significa el prefijo @b64@ en las variables?
- ¿Qué significa el prefijo @url@ en las variables?

Variables Condicionadas (Scoped Variables)

- ¿Cómo puedo usar variables diferentes según la rama o entorno?
- ¿Qué es una "scoped variable"?
- ¿Cuál es la sintaxis para variables condicionadas?
- ¿Qué operadores están disponibles para condiciones (equals, contains, etc.)?
- ¿En qué secciones funcionan las scoped variables?
- ¿Por qué las scoped variables no funcionan en parámetros de imagen?

Proxy y Certificados

- ¿Cómo configuro un proxy HTTP/HTTPS en los pipelines?
- ¿Cómo añado certificados CA personalizados?
- ¿Qué variable uso para certificados adicionales?

Gestión de Ramas y Referencias Git

- ¿Cómo defino qué ramas son de producción?
- ¿Cómo configuro el patrón de ramas de integración?
- ¿Qué es PROD_REF, INTEG_REF y RELEASE_REF?
- ¿Puedo personalizar los patrones regex de las ramas?

Control de Ejecución de Pipelines

- ¿Cómo omito la ejecución del pipeline en ciertos contextos?
- ¿Qué es [skip ci on <words>] y cómo funciona?
- ¿Puedo saltarme el pipeline solo en merge requests pero no en tags?
- ¿Qué palabras clave acepta el skip selectivo (tag, mr, branch, etc.)?

Workflow y Merge Requests

- ¿Cuál es la estrategia por defecto de merge request pipelines?
- ¿Cómo cambio de merge request pipeline a branch pipeline?
- ¿Qué es el workflow de to-be-continuous?

Políticas de Tests y Pipeline Adaptativo

- ¿Qué es la "adaptive pipeline strategy"?
- ¿Cuándo se ejecutan los tests automáticamente vs manualmente?
- ¿Qué es .test-policy y .acceptance-policy?
- ¿Cómo fuerzo la ejecución de todos los jobs sin importar la fase?
- ¿Qué hace la variable ADAPTIVE_PIPELINE_DISABLED?

Personalización Avanzada (YAML Override)

- ¿Cómo sobreescribo configuraciones de templates incluidos?
- ¿Cómo añado servicios adicionales (MySQL, PostgreSQL) a los tests?
- ¿Cómo configuro runners privados con proxy?
- ¿Cómo deshabilito jobs específicos del template?
- ¿Puedo hacer que los tests fallen sin romper el pipeline?
- ¿Qué es el "hidden base job" de cada template?

Monorepos y Múltiples Instancias

- ¿Cómo uso múltiples instancias del mismo template en un monorepo?
- ¿Qué es parallel:matrix y cómo funciona?
- ¿Puedo ejecutar el mismo template con diferentes versiones de Python/Node/etc?
- ¿Por qué parallel:matrix no es compatible con la sintaxis de inputs?
- ¿Cómo configuro diferentes directorios de proyecto en un monorepo?

Preguntas Generales

- ¿Qué es "to be continuous"?
- ¿Para qué sirve esta documentación?
- ¿Dónde encuentro ejemplos prácticos de configuración?
