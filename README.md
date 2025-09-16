# Proyectos Informáticos – MySQL (CRUD + UDF + Triggers)

Repositorio listo para ejecutar en **Visual Studio Code** (o cualquier editor) y validar en **MySQL 8.0+**.

**Institución:** IUDigital de Antioquia  
**Curso:** Base de Datos  
**Docente:** Julian Loaiza

---

## 🎯 Objetivo
Implementar en **MySQL**:
- CRUD por procedimientos almacenados para 2 tablas (`docente` y `proyecto`).
- 1 **UDF** con operación matemática (promedio de presupuesto).
- **Triggers** de auditoría para ACTUALIZADOS y ELIMINADOS.

---

## 📂 Estructura
```
S20---Evidencia-de-Aprendizaje-2.-Taller-pr-ctico/
├─ README.md
├─ 00_create_database.sql
├─ 01_schema.sql
├─ 02_seed.sql
├─ 03_queries.sql
```

---

## 🚀 Ejecución rápida (MySQL Workbench o CLI)
En la consola de MySQL, estando en la carpeta del proyecto:
```sql
SOURCE sql/00_create_database.sql;
SOURCE sql/01_schema.sql;
SOURCE sql/02_seed.sql;
SOURCE sql/03_queries.sql;
```

> Requiere **MySQL 8.0.16+** para que los `CHECK` se apliquen.

---

## 🧩 Solución implementada
- **Tablas:** `docente`, `proyecto` (1:N).
- **Procedimientos:** `sp_docente_*`, `sp_proyecto_*`.
- **UDF:** `fn_promedio_presupuesto_por_docente` (AVG).
- **Triggers:** `tr_docente_after_update`, `tr_docente_after_delete`.
- **Consultas:** `03_queries.sql` incluye **Q0–Q9** (creación BD, inserciones vía SP y directas, auditoría y validaciones).

---

## 🌐 Landing
Abrir `landing/index.html` con Live Server (VS Code) o cualquier servidor estático:
```
cd landing
# ejemplo con Python
python -m http.server 8080
# abre http://localhost:8080
```

---

## 📜 Licencia
Uso académico.
