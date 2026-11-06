Unit palabras_claves;
{$H+}

Interface

{ ================================================================ }
{  Palabras_claves.pas - Vocabulario del chatbot                   }
{  Todos los textos van en minusculas y sin tildes para que los    }
{  validadores coincidan siempre con el archivo de datos.          }
{ ================================================================ }

Const
  { Cantidad exacta de generos detectados }
  CANT_GENEROS = 20;
  genero: array[1..CANT_GENEROS] Of string = (
                 'accion', 'aventura', 'comedia', 'drama',
                 'animacion', 'fantasia', 'sci-fi', 'terror',
                 'thriller', 'romance', 'musical', 'familiar',
                 'misterio', 'crimen', 'biografia', 'deporte',
                 'guerra', 'espionaje', 'sobrenatural', 'historia');

  CANT_FRANQUICIAS = 30;
  franquicia: array[1..CANT_FRANQUICIAS] Of string = (
                'spiderman', 'spider-man', 'batman', 'terminator',
                'lotr', 'hobbit', 'harry potter', 'harry_potter',
                'harry poter', 'jurassic', 'autos', 'john wick',
                'john_wick', 'joker', 'marvel', 'star wars',
                'star_wars', 'alien', 'scream', 'saw', 'conjuring',
                'matrix', 'dreamworks', 'pixar', 'ghibli',
                'disney', 'mission impossible', 'mission_impossible',
                'piratas', 'rocky');

  CANT_EPOCAS = 27;
  epoca: array[1..CANT_EPOCAS] Of string = (
           'los 50', 'cincuenta', 'los 60', 'sesenta', 'decada del 60',
           'los 70', 'setenta', 'decada del 70',
           'los 80', 'ochenta', 'decada del 80',
           'los 90', 'noventa', 'decada del 90',
           'clasicos', 'clasicas', 'antiguo', 'vieja', 'viejo',
           'recientes', 'moderno', 'actual',
           'siglo 20', 'siglo 21', 'siglo xx', 'siglo xxi',
           'milenio');

  CANT_DIRECTOR_TRIGGERS = 10;
  directores: array[1..CANT_DIRECTOR_TRIGGERS] Of string = (
                'dirigidas por', 'dirigida por', 'dirigido por',
                'dirigieron', 'dirigida', 'dirigidas', 'dirigido',
                'dirigidos', 'director de', 'director');

  CANT_ACTOR_TRIGGERS = 14;
  actores: array[1..CANT_ACTOR_TRIGGERS] Of string = (
             'protagonizada por', 'protagonizado por',
             'protagonizada', 'protagonizada ',
             'protagonizan', 'protagoniza',
             'actua en', 'actua', 'actuo', 'actuando',
             'actuaron', 'interpreta', 'interpretada por',
             'participa');

  CANT_ME_GUSTA_TRIGGERS = 7;
  me_gusta: array[1..CANT_ME_GUSTA_TRIGGERS] Of string = (
              'me gustaria', 'me gustarian', 'me gustan',
              'me gusta', 'gustaria', 'me encanta', 'gustan');

  CANT_PARECIDA_TRIGGERS = 7;
  parecida: array[1..CANT_PARECIDA_TRIGGERS] Of string = (
              'algo similar a', 'parecidas a', 'parecidos a',
              'parecida a', 'parecido a', 'similar a', 'del estilo a');

  CANT_AZAR_TRIGGERS = 14;
  al_azar: array[1..CANT_AZAR_TRIGGERS] Of string = (
             'al azar', 'aleatoria', 'aleatorio', 'sorprendeme',
             'sorprenderme', 'cualquiera', 'recomendame algo',
             'recomendame', 'recomenda', 'que me recomendarias',
             'que me recomendas', 'algo random', 'random', 'sorpresa');

  CANT_ETIQUETA_TRIGGERS = 8;
  etiqueta: array[1..CANT_ETIQUETA_TRIGGERS] Of string = (
              'algo con', 'algo de', 'con un', 'con una',
              'que tenga', 'que tengan', 'sobre', 'tematica');

  CANT_SALUDOS = 6;
  saludo: array[1..CANT_SALUDOS] Of string = (
            'hola', 'buenos dias', 'buen dia', 'buenas tardes',
            'buenas noches', 'buenas');

  CANT_DESPEDIDAS = 12;
  despedida: array[1..CANT_DESPEDIDAS] Of string = (
               'adios', 'chau', 'chao', 'hasta luego',
               'nos vemos', 'cuidate', 'hasta pronto',
               'hasta la proxima', 'hasta manana', 'saludos',
               'me voy', 'bye');

  CANT_RESP_SALUDO = 6;
  resp_saludo: array[1..CANT_RESP_SALUDO] Of string = (
                 'Hola! Que bueno verte por aca.',
                 'Hola! Listo para recomendar peliculas.',
                 'Hola! Contame que genero te tira hoy.',
                 'Bienvenido! Aca el cinemero personal.',
                 'Hola hola! Buscas algo para ver?',
                 'Buenas! Yo conozco todas las pelis');

  CANT_RESP_POSITIVAS = 8;
  resp_positivas: array[1..CANT_RESP_POSITIVAS] Of string = (
                    'Genial, encontre esto para vos',
                    'Anotado, mira lo que tengo',
                    'Buenisimo, aca va',
                    'Perfecto, esto te puede copar',
                    'Lindo pedido, mira',
                    'Me encanta ese gusto, aca tenes',
                    'Dale, esto te va a gustar',
                    'Encontre algo que puede ir');

  CANT_RESP_NEGATIVAS = 8;
  resp_negativas: array[1..CANT_RESP_NEGATIVAS] Of string = (
                    'Uy, no encontre nada con eso',
                    'No tengo nada que coincida, proba de otra forma',
                    'Me quede en blanco con esa busqueda',
                    'No hay resultados para eso',
                    'Mmm, no caché que buscas exactamente',
                    'No encontre coincidencias, pero proba con un genero',
                    'No esta en mi base eso, pruebe otra cosa',
                    'No tengo registro de eso');

  CANT_RESP_FIN = 6;
  resp_fin: array[1..CANT_RESP_FIN] Of string = (
              'Podes pedirme otra, buscar por genero o mandarme una saga.',
              'Segui escribiendo y te sigo recomendando.',
              'Proba con "dame algo al azar" si no tenes idea.',
              'Tambien puedo decirte datos: "quien es el director con mas peliculas?".',
              'Si queres estadisticas, preguntame "cual fue la mas vista".',
              'Decime "me gusta X" y busco parecidas.');

  { Palabras que no aportan nada en una frase suelta }
  CANT_STOPWORDS = 52;
  stopwords: array[1..CANT_STOPWORDS] Of string = (
               'de', 'la', 'el', 'los', 'las', 'un', 'una',
               'unos', 'unas', 'y', 'o', 'que', 'con', 'me',
               'te', 'se', 'su', 'mis', 'tus', 'al', 'del',
               'en', 'por', 'para', 'no', 'si', 'quiero',
               'queria', 'quieres', 'necesito', 'quieras',
               'dame', 'busco', 'busque', 'buscando',
               'tenes', 'tener', 'tiene', 'tengas',
               'alguna', 'algun', 'algunas', 'algunos',
               'pelicula', 'peliculas', 'peli', 'pelis',
               'ver', 'saber', 'hay', 'son', 'es');

  CANT_RESPUESTAS_INFO = 8;
  resp_info: array[1..CANT_RESPUESTAS_INFO] Of string = (
               'Con eso te paso data de la base.',
               'Chequeo mis numeros y te digo.',
               'Dejala, yo tengo las estadisticas.',
               'Buen dato para preguntar.',
               'Enseguida saco la cuenta.',
               'Mis numeros dicen esto.',
               'Dato confirmado, mira.',
               'Lo tengo de memoria.');

Implementation

End.