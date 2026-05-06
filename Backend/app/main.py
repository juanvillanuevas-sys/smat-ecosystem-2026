from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from pydantic import BaseModel

# ESTO ES LO QUE FALTA: importar schemas y crud
from . import models, schemas, crud  
from .database import engine, get_db

# ==========================================================
# CREACIÓN DE LA BASE DE DATOS Y TABLAS
# ==========================================================
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="SMAT - Sistema de Monitoreo de Alerta Temprana",
    description="""
    API robusta para la gestión y monitoreo de desastres naturales.
    Permite la telemetría de sensores en tiempo real y el cálculo de niveles de riesgo.
    
    **Entidades principales:**
    * **Estaciones:** Puntos de monitoreo físico.
    * **Lecturas:** Datos capturados por sensores.
    * **Riesgos:** Análisis de criticidad basado en umbrales.
    """,
    version="1.0.0",
    terms_of_service="http://unmsm.edu.pe/terms/",
    contact={
        "name": "Soporte Técnico SMAT - FISI",
        "url": "http://fisi.unmsm.edu.pe",
        "email": "desarrollo.smat@unmsm.edu.pe",
    },
    license_info={
        "name": "Apache 2.0",
        "url": "https://www.apache.org/licenses/LICENSE-2.0.html",
    },
)

# Configuración de orígenes permitidos
origins = ["*"] 
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # El asterisco permite que Edge se conecte sin problemas
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==========================================================
# ENDPOINTS
# ==========================================================

@app.post(
    "/estaciones/",
    status_code=201,
    tags=["Gestión de Infraestructura"],
    summary="Registrar una nueva estación de monitoreo",
    description="Inserta una estación física (ej. río, volcán, zona sísmica) en la base de datos."
)
def crear_estacion(estacion: schemas.EstacionCreate, db: Session = Depends(get_db)):
    # Lógica delegada a crud.py
    nueva_estacion = crud.crear_estacion(
        db, 
        id=estacion.id, 
        nombre=estacion.nombre, 
        ubicacion=estacion.ubicacion
    )
    return {"msj": "Estación guardada en DB", "data": nueva_estacion}


@app.post(
    "/lecturas/",
    status_code=201,
    tags=["Telemetría de Sensores"],
    summary="Recibir datos de telemetría",
    description="Recibe el valor capturado por un sensor y lo vincula a una estación existente."
)
def registrar_lectura(lectura: schemas.LecturaCreate, db: Session = Depends(get_db)):
    # Validación de existencia usando crud.py
    estacion = crud.obtener_estacion_por_id(db, lectura.estacion_id)

    if not estacion:
        raise HTTPException(status_code=404, detail="Estación no existe")

    # Persistencia usando crud.py
    crud.registrar_lectura(db, valor=lectura.valor, estacion_id=lectura.estacion_id)

    return {"status": "Lectura recibida"}


@app.get(
    "/estaciones/",
    tags=["Gestión de Infraestructura"],
    summary="Listar estaciones",
    description="Muestra todas las estaciones registradas."
)
def obtener_estaciones(db: Session = Depends(get_db)):
    estaciones = crud.obtener_estaciones(db)

    if not estaciones:
        raise HTTPException(status_code=404, detail="No hay estaciones registradas")

    return estaciones


@app.get(
    "/estaciones/{id}/riesgo",
    tags=["Análisis de Riesgo"],
    summary="Evaluar nivel de riesgo actual",
    description="Analiza la última lectura de una estación y determina si el estado es NORMAL, ALERTA o PELIGRO."
)
def obtener_riesgo(id: int, db: Session = Depends(get_db)):
    estacion = crud.obtener_estacion_por_id(db, id)

    if not estacion:
        raise HTTPException(status_code=404, detail="Estación no encontrada")

    lecturas = crud.obtener_lecturas_por_estacion(db, id)

    if not lecturas:
        return {"id": id, "nivel": "SIN DATOS", "valor": 0}

    ultima_lectura = lecturas[-1].valor

    if ultima_lectura > 20.0:
        nivel = "PELIGRO"
    elif ultima_lectura > 10.0:
        nivel = "ALERTA"
    else:
        nivel = "NORMAL"

    return {"id": id, "valor": ultima_lectura, "nivel": nivel}


@app.get(
    "/estaciones/{id}/historial-resumen",
    tags=["Historial de Lecturas"],
    summary="Historial con estadísticas",
    description="Devuelve lecturas, conteo y promedio de una estación."
)
def obtener_historial_resumen(id: int, db: Session = Depends(get_db)):
    estacion = crud.obtener_estacion_por_id(db, id)

    if not estacion:
        raise HTTPException(status_code=404, detail="Estación no encontrada")

    lecturas = crud.obtener_lecturas_por_estacion(db, id)
    valores = [l.valor for l in lecturas]

    if len(valores) > 0:
        promedio = sum(valores) / len(valores)
    else:
        promedio = 0.0

    return {
        "estacion_id": id,
        "lecturas": valores,
        "conteo": len(valores),
        "promedio": round(promedio, 2)
    }


@app.get(
    "/reportes/criticos",
    tags=["Auditoría"],
    summary="Estaciones críticas",
    description="Lista estaciones cuya última lectura supera un umbral."
)
def obtener_criticos(umbral: float = 20.0, db: Session = Depends(get_db)):
    estaciones = crud.obtener_estaciones(db)
    resultado = []

    for est in estaciones:
        lecturas = crud.obtener_lecturas_por_estacion(db, est.id)
        if lecturas:
            ultima = lecturas[-1].valor
            if ultima > umbral:
                resultado.append({
                    "estacion_id": est.id,
                    "valor": ultima
                })

    return {
        "umbral": umbral,
        "total": len(resultado),
        "data": resultado
    }


@app.get("/estaciones/stats", tags=["Resumen Ejecutivo"])
def obtener_stats(db: Session = Depends(get_db)):
    # Usamos tus funciones de crud sin modificarlas
    estaciones = crud.obtener_estaciones(db)
    lecturas = crud.obtener_todas_las_lecturas(db)

    total_est = len(estaciones)
    total_lec = len(lecturas)

    # Buscamos el máximo manualmente
    valor_max = 0.0
    id_max = None
    for l in lecturas:
        if l.valor > valor_max:
            valor_max = l.valor
            id_max = l.estacion_id

    return {
        "total_estaciones_monitoreadas": total_est,
        "total_lecturas_procesadas": total_lec,
        "punto_critico_maximo": {
            "estacion_id": id_max,
            "valor_lectura": valor_max
        }
    }