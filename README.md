# Sistema de Auditoría Sincronizada (MQTT + Flutter)

> **Solución de captura fotográfica simultánea para la verificación de instrumentos eléctricos con arquitectura Maestro-Esclavo.**

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![MQTT](https://img.shields.io/badge/MQTT-%23660066.svg?style=for-the-badge&logo=mqtt&logoColor=white)
![GraphQL](https://img.shields.io/badge/-GraphQL-E10098?style=for-the-badge&logo=graphql&logoColor=white)

---

## 📌 Resumen del Proyecto

Este proyecto consiste en un ecosistema de aplicaciones móviles diseñado para eliminar el error humano y el desfase temporal en la auditoría de mediciones eléctricas. Mediante una arquitectura **Maestro-Esclavo**, el sistema permite que dos dispositivos en ubicaciones distintas realicen una captura fotográfica en el mismo milisegundo, permitiendo comparar lecturas y determinar desviaciones técnicas con precisión científica.

## ⚠️ El Desafío

En entornos industriales, las mediciones eléctricas fluctúan constantemente. Tomar fotografías de instrumentos con solo unos segundos de diferencia genera datos inconsistentes que impiden una comparación real. El reto principal fue lograr una **sincronización de latencia casi nula** entre dispositivos heterogéneos.

---

## 🛠️ Solución Técnica

### Arquitectura de Comunicación
El sistema utiliza un **Broker MQTT** como orquestador central. La comunicación se basa en un flujo de estados:
1.  **Handshake:** El Maestro solicita sincronización.
2.  **Ready Check:** El Esclavo confirma que la cámara y los sensores están listos.
3.  **Trigger:** El Maestro envía la señal de disparo y ambos dispositivos ejecutan la captura simultáneamente.

### Procesamiento de Datos (Edge Computing)
La aplicación Maestro (Fluter) no solo captura la imagen, sino que integra la lógica de negocio:
* Calcula la diferencia entre lecturas de forma inmediata.
* Aplica fórmulas de error porcentual.
* Valida si la diferencia se encuentra dentro de los rangos de tolerancia permitidos.

---

## 🚀 Stack Tecnológico

* **Frontend:** [Flutter](https://flutter.dev/) (Apps para Android/iOS).
* **Mensajería:** [MQTT](https://mqtt.org/) para orquestación en tiempo real.
* **Persistencia:** Backend basado en **GraphQL** para una gestión eficiente de muestras y metadatos.
* **Hardware:** Optimización de la API de cámara para reducir el tiempo de respuesta del obturador.

---


## 📈 Impacto y Resultados

* **Precisión:** Eliminación total de la variable de desfase temporal en las auditorías.
* **Eficiencia:** Digitalización inmediata de la desviación, eliminando el procesamiento manual posterior.

---

> **Nota:** Este es un proyecto de uso interno empresarial. El acceso al código fuente del backend y las llaves de API están restringidos por políticas de seguridad de la compañía.
