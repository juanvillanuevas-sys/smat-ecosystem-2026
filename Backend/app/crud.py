from sqlalchemy.orm import Session
from . import models

def crear_estacion(db: Session, id: int, nombre: str, ubicacion: str):
    nueva_estacion = models.EstacionDB(
        id=id,
        nombre=nombre,
        ubicacion=ubicacion
    )
    db.add(nueva_estacion)
    db.commit()
    db.refresh(nueva_estacion)
    return nueva_estacion

def obtener_estaciones(db: Session):
    return db.query(models.EstacionDB).all()

def obtener_estacion_por_id(db: Session, id: int):
    return db.query(models.EstacionDB).filter(models.EstacionDB.id == id).first()

def registrar_lectura(db: Session, valor: float, estacion_id: int):
    nueva_lectura = models.LecturaDB(
        valor=valor,
        estacion_id=estacion_id
    )
    db.add(nueva_lectura)
    db.commit()
    return nueva_lectura

def obtener_lecturas_por_estacion(db: Session, id: int):
    return db.query(models.LecturaDB).filter(models.LecturaDB.estacion_id == id).all()

def obtener_todas_las_lecturas(db: Session):
    return db.query(models.LecturaDB).all()