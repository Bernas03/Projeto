from fastapi import FastAPI, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy import Column, Integer, String, Float, DateTime, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime

# Configuração do banco de dados
SQLALCHEMY_DATABASE_URL = 'mysql+pymysql://Bernardo:teste123@83.212.126.14:3306/Projeto'  # ou use o URL do seu banco de dados
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Modelos do SQLAlchemy
class Cuidador(Base):
    __tablename__ = 'Cuidador'
    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String, nullable=False)
    email = Column(String, nullable=False)
    password = Column(String, nullable=False)
    cargo = Column(String, nullable=False)

class Mensagem(Base):
    __tablename__ = 'Mensagem'
    id = Column(Integer, primary_key=True, index=True)
    id_cuidador = Column(Integer, nullable=False)
    id_paciente = Column(Integer, nullable=False)
    mensagem = Column(String, nullable=False)

class Paciente(Base):
    __tablename__ = 'Paciente'
    id = Column(Integer, primary_key=True, index=True)
    id_cuidador = Column(Integer, nullable=False)
    id_sensor = Column(Integer, nullable=False)
    codigo = Column(String, nullable=False)
    nome = Column(String, nullable=False)
    data_de_nascimento = Column(DateTime, nullable=False)
    genero = Column(String, nullable=False)
    altura = Column(Integer, nullable=False)
    peso = Column(Float, nullable=False)
    condicao = Column(String, nullable=False)
    descricao = Column(String, nullable=False)

class Sensor(Base):
    __tablename__ = 'Sensor'
    id = Column(Integer, primary_key=True, index=True)
    mac_adress = Column(String, nullable=False)
    dados = Column(String, nullable=False)

# Modelos Pydantic
class CuidadorCreate(BaseModel):
    id: int
    nome: str
    email: str
    password: str
    cargo: str

class CuidadorUpdate(BaseModel):
    nome: str
    email: str
    password: str
    cargo: str

class MensagemCreate(BaseModel):
    id: int
    id_cuidador: int
    id_paciente: int
    mensagem: str

class MensagemUpdate(BaseModel):
    id_cuidador: int
    id_paciente: int
    mensagem: str

class PacienteCreate(BaseModel):
    id: int
    id_cuidador: int
    id_sensor: int
    codigo: str
    nome: str
    data_de_nascimento: datetime
    genero: str
    altura: int
    peso: float
    condicao: str
    descricao: str

class PacienteUpdate(BaseModel):
    id_cuidador: int
    id_sensor: int
    codigo: str
    nome: str
    data_de_nascimento: datetime
    genero: str
    altura: int
    peso: float
    condicao: str
    descricao: str

class SensorCreate(BaseModel):
    id: int
    mac_adress: str
    dados: str

class SensorUpdate(BaseModel):
    mac_adress: str
    dados: str

# Inicialização do banco de dados
def init_db():
    Base.metadata.create_all(bind=engine)

# Dependência do banco de dados
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Inicialização da aplicação FastAPI
app = FastAPI()

# Adicionando o middleware CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Permite todas as origens. Para maior segurança, especifique as origens permitidas.
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Cuidador - CRUD
@app.post("/cuidadores/")
def create_cuidador(cuidador: CuidadorCreate, db: Session = Depends(get_db)):
    db_cuidador = Cuidador(**cuidador.dict())
    db.add(db_cuidador)
    db.commit()
    db.refresh(db_cuidador)
    return db_cuidador

@app.get("/cuidadores/{cuidador_id}")
def read_cuidador(cuidador_id: int, db: Session = Depends(get_db)):
    db_cuidador = db.query(Cuidador).filter(Cuidador.id == cuidador_id).first()
    if db_cuidador is None:
        raise HTTPException(status_code=404, detail="Cuidador not found")
    return db_cuidador

@app.put("/cuidadores/{cuidador_id}")
def update_cuidador(cuidador_id: int, cuidador: CuidadorUpdate, db: Session = Depends(get_db)):
    db_cuidador = db.query(Cuidador).filter(Cuidador.id == cuidador_id).first()
    if db_cuidador is None:
        raise HTTPException(status_code=404, detail="Cuidador not found")
    for key, value in cuidador.dict().items():
        setattr(db_cuidador, key, value)
    db.commit()
    db.refresh(db_cuidador)
    return db_cuidador

@app.delete("/cuidadores/{cuidador_id}")
def delete_cuidador(cuidador_id: int, db: Session = Depends(get_db)):
    db_cuidador = db.query(Cuidador).filter(Cuidador.id == cuidador_id).first()
    if db_cuidador is None:
        raise HTTPException(status_code=404, detail="Cuidador not found")
    db.delete(db_cuidador)
    db.commit()
    return {"message": "Cuidador deleted successfully"}

# Mensagem - CRUD
@app.post("/mensagens/")
def create_mensagem(mensagem: MensagemCreate, db: Session = Depends(get_db)):
    db_mensagem = Mensagem(**mensagem.dict())
    db.add(db_mensagem)
    db.commit()
    db.refresh(db_mensagem)
    return db_mensagem

@app.get("/mensagens/{mensagem_id}")
def read_mensagem(mensagem_id: int, db: Session = Depends(get_db)):
    db_mensagem = db.query(Mensagem).filter(Mensagem.id == mensagem_id).first()
    if db_mensagem is None:
        raise HTTPException(status_code=404, detail="Mensagem not found")
    return db_mensagem

@app.put("/mensagens/{mensagem_id}")
def update_mensagem(mensagem_id: int, mensagem: MensagemUpdate, db: Session = Depends(get_db)):
    db_mensagem = db.query(Mensagem).filter(Mensagem.id == mensagem_id).first()
    if db_mensagem is None:
        raise HTTPException(status_code=404, detail="Mensagem not found")
    for key, value in mensagem.dict().items():
        setattr(db_mensagem, key, value)
    db.commit()
    db.refresh(db_mensagem)
    return db_mensagem

@app.delete("/mensagens/{mensagem_id}")
def delete_mensagem(mensagem_id: int, db: Session = Depends(get_db)):
    db_mensagem = db.query(Mensagem).filter(Mensagem.id == mensagem_id).first()
    if db_mensagem is None:
        raise HTTPException(status_code=404, detail="Mensagem not found")
    db.delete(db_mensagem)
    db.commit()
    return {"message": "Mensagem deleted successfully"}

# Paciente - CRUD
@app.post("/pacientes/")
def create_paciente(paciente: PacienteCreate, db: Session = Depends(get_db)):
    db_paciente = Paciente(**paciente.dict())
    db.add(db_paciente)
    db.commit()
    db.refresh(db_paciente)
    return db_paciente

@app.get("/pacientes/{paciente_id}")
def read_paciente(paciente_id: int, db: Session = Depends(get_db)):
    db_paciente = db.query(Paciente).filter(Paciente.id == paciente_id).first()
    if db_paciente is None:
        raise HTTPException(status_code=404, detail="Paciente not found")
    return db_paciente

@app.put("/pacientes/{paciente_id}")
def update_paciente(paciente_id: int, paciente: PacienteUpdate, db: Session = Depends(get_db)):
    db_paciente = db.query(Paciente).filter(Paciente.id == paciente_id).first()
    if db_paciente is None:
        raise HTTPException(status_code=404, detail="Paciente not found")
    for key, value in paciente.dict().items():
        setattr(db_paciente, key, value)
    db.commit()
    db.refresh(db_paciente)
    return db_paciente

@app.delete("/pacientes/{paciente_id}")
def delete_paciente(paciente_id: int, db: Session = Depends(get_db)):
    db_paciente = db.query(Paciente).filter(Paciente.id == paciente_id).first()
    if db_paciente is None:
        raise HTTPException(status_code=404, detail="Paciente not found")
    db.delete(db_paciente)
    db.commit()
    return {"message": "Paciente deleted successfully"}

# Sensor - CRUD
@app.post("/sensores/")
def create_sensor(sensor: SensorCreate, db: Session = Depends(get_db)):
    db_sensor = Sensor(**sensor.dict())
    db.add(db_sensor)
    db.commit()
    db.refresh(db_sensor)
    return db_sensor

@app.get("/sensores/{sensor_id}")
def read_sensor(sensor_id: int, db: Session = Depends(get_db)):
    db_sensor = db.query(Sensor).filter(Sensor.id == sensor_id).first()
    if db_sensor is None:
        raise HTTPException(status_code=404, detail="Sensor not found")
    return db_sensor

@app.put("/sensores/{sensor_id}")
def update_sensor(sensor_id: int, sensor: SensorUpdate, db: Session = Depends(get_db)):
    db_sensor = db.query(Sensor).filter(Sensor.id == sensor_id).first()
    if db_sensor is None:
        raise HTTPException(status_code=404, detail="Sensor not found")
    for key, value in sensor.dict().items():
        setattr(db_sensor, key, value)
    db.commit()
    db.refresh(db_sensor)
    return db_sensor

@app.delete("/sensores/{sensor_id}")
def delete_sensor(sensor_id: int, db: Session = Depends(get_db)):
    db_sensor = db.query(Sensor).filter(Sensor.id == sensor_id).first()
    if db_sensor is None:
        raise HTTPException(status_code=404, detail="Sensor not found")
    db.delete(db_sensor)
    db.commit()
    return {"message": "Sensor deleted successfully"}

# Inicializa o banco de dados
init_db()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
