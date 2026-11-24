// Faux serveur d'authentification pour json-server.
// POST /login  { email, password }  ->  { token, user }
// Toutes les autres routes exigent l'en-tête  Authorization: Bearer <token>.
const TOKEN = 'campusflow-fake-jwt-token';

module.exports = (req, res, next) => {
  if (req.method === 'POST' && req.path === '/login') {
    const { email, password } = req.body || {};
    if (email === 'etudiant@campus.bf' && password === 'campus123') {
      return res.json({
        token: TOKEN,
        user: { id: 1, nom: 'Idrissa', email },
      });
    }
    return res.status(401).json({ message: 'Identifiants invalides' });
  }

  if (req.headers.authorization === `Bearer ${TOKEN}`) {
    return next();
  }
  return res.status(401).json({ message: 'Non autorisé' });
};
