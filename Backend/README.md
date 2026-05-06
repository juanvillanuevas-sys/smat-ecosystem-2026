//Codigos Curl usados
curl -X POST "http://127.0.0.1:8000/estaciones/" \-H "Content-Type: application/json" \-d '{"id": 1, "nombre": "Estación Central Rímac", "ubicacion": "Chosica"}'  //CREACION
curl -X POST "http://127.0.0.1:8000/lecturas/" \-H "Content-Type: application/json" \-d '{"estacion_id": 1, "valor": 75.8}' //REGISTRO

