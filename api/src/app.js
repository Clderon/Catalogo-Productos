import express from "express";
import jwt from "jsonwebtoken";
import mysql from "mysql2/promise";

const app = express();
app.use(express.json());

// Conexión a la base de datos usando variables de entorno del Secret
const db = await mysql.createConnection({
  host: process.env.DB_HOST,      // mysql
  user: process.env.DB_USER,      // root
  password: process.env.DB_PASSWORD, // example
  database: "inventory_db",  
  port: process.env.DB_PORT       // 3306
});

// Middleware para verificar JWT
function auth(req, res, next) {
  const header = req.headers.authorization;
  if (!header) return res.status(401).json({ error: "Token requerido" });

  const token = header.split(" ")[1];
  try {
    jwt.verify(token, process.env.JWT_SECRET); // supersecretojwt
    next();
  } catch (err) {
    return res.status(403).json({ error: "Token inválido" });
  }
}

// Ruta GET pública
app.get("/productos", async (req, res) => {
  const [rows] = await db.query("SELECT * FROM productos");
  res.json(rows);
});

// Ruta POST protegida
app.post("/productos", auth, async (req, res) => {
  const { nombre, categoria_id } = req.body;

  await db.query(
    "INSERT INTO productos (nombre, categoria_id) VALUES (?, ?)",
    [nombre, categoria_id]
  );

  res.json({ message: "Producto agregado" });
});

// Ruta PUT protegida
app.put("/productos/:id", auth, async (req, res) => {
  const { id } = req.params;
  const { nombre, categoria_id } = req.body;

  await db.query(
    "UPDATE productos SET nombre=?, categoria_id=? WHERE id=?",
    [nombre, categoria_id, id]
  );

  res.json({ message: "Producto actualizado" });
});


app.get("/categorias", async (req, res) => {
  const [rows] = await db.query("SELECT * FROM categorias");
  res.json(rows);
});

app.post("/categorias", auth, async (req, res) => {
  const { nombre } = req.body;

  if (!nombre) return res.status(400).json({ error: "El nombre es requerido" });

  await db.query("INSERT INTO categorias (nombre) VALUES (?)", [nombre]);

  res.json({ message: "Categoría agregada correctamente" });
});

app.put("/categorias/:id", auth, async (req, res) => {
  const { id } = req.params;
  const { nombre } = req.body;

  await db.query("UPDATE categorias SET nombre=? WHERE id=?", [nombre, id]);

  res.json({ message: "Categoría actualizada correctamente" });
});

app.delete("/categorias/:id", auth, async (req, res) => {
  const { id } = req.params;

  await db.query("DELETE FROM categorias WHERE id=?", [id]);

  res.json({ message: "Categoría eliminada correctamente" });
});


// Iniciar API
app.listen(3000, () => console.log("API corriendo en puerto 3000"));
