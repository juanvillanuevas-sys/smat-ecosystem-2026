from pydantic import BaseModel
from typing import List, Optional

# ==========================================================
# ESQUEMAS PARA LECTURAS
# ==========================================================

class LecturaBase(BaseModel):
    valor: float
    estacion_id: int

class LecturaCreate(LecturaBase):
    """Esquema para recibir datos del sensor"""
    pass

class Lectura(LecturaBase):
    """Esquema para devolver datos de la base de datos"""
    id: int

    class Config:
        from_attributes = True


# ==========================================================
# ESQUEMAS PARA ESTACIONES
# ==========================================================

class EstacionBase(BaseModel):
    id: int
    nombre: str
    ubicacion: str

class EstacionCreate(EstacionBase):
    """Esquema para registrar una nueva estación"""
    pass

class Estacion(EstacionBase):
    """Esquema para devolver datos de la estación"""
    # Si quieres que al listar estaciones se vean sus lecturas,
    # puedes descomentar la siguiente línea:
    # lecturas: List[Lectura] = []

    class Config:
        from_attributes = True


# ==========================================================
# ESQUEMAS DE RESPUESTA ESPECIALES (REPORTES)
# ==========================================================

class ResumenEstacion(BaseModel):
    estacion_id: int
    lecturas: List[float]
    conteo: int
    promedio: float

class RiesgoEstacion(BaseModel):
    id: int
    valor: float
    nivel: str # NORMAL, ALERTA, PELIGRO