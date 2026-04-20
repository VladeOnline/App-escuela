const axios = require('axios');

const registerTeacher = async () => {
  try {
    const response = await axios.post('http://localhost:3000/api/auth/registrar', {
      nombre: 'Prof. Juan García',
      username: 'juangarcia',
      password: 'Profesor123!'
    });
    console.log('✅ Docente registrado exitosamente:');
    console.log(JSON.stringify(response.data, null, 2));
  } catch (error) {
    console.error('❌ Error al registrar docente:', error.response?.data || error.message);
  }
};

registerTeacher();
