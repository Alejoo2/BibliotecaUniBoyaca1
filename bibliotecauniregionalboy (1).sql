-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 08-04-2026 a las 14:27:50
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `bibliotecauniregionalboy`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_devolver_libro` (IN `p_id_prestamo` INT)   BEGIN
  DECLARE v_id_libro INT;
  DECLARE v_fecha_esperada DATE;
  DECLARE v_dias_retraso INT;


  SELECT id_libro, fecha_devolucion_esperada
  INTO v_id_libro, v_fecha_esperada
  FROM prestamo WHERE id_prestamo = p_id_prestamo;


  UPDATE prestamo
  SET fecha_devolucion_real = CURDATE(),
      estado = 'DEVUELTO'
  WHERE id_prestamo = p_id_prestamo;


  UPDATE libro SET disponible = TRUE WHERE id_libro = v_id_libro;


  -- Calcular d\u00edas de retraso y generar multa autom\u00e1tica
  SET v_dias_retraso = DATEDIFF(CURDATE(), v_fecha_esperada);
  IF v_dias_retraso > 0 THEN
    INSERT INTO multa (id_prestamo, monto, fecha)
    VALUES (p_id_prestamo, v_dias_retraso * 2000, CURDATE());
    SELECT CONCAT('Libro devuelto con ', v_dias_retraso, ' d\u00edas de retraso. Multa generada.') AS mensaje;
  ELSE
    SELECT 'Libro devuelto a tiempo. Sin multa.' AS mensaje;
  END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_generar_multa` (IN `p_id_prestamo` INT, IN `p_monto` DECIMAL(10,2))   BEGIN
  INSERT INTO multa (id_prestamo, monto, fecha)
  VALUES (p_id_prestamo, p_monto, CURDATE());
  SELECT 'Multa generada correctamente' AS mensaje;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_prestamo` (IN `p_id_libro` INT, IN `p_id_usuario` INT, IN `p_dias` INT)   BEGIN
  DECLARE v_disponible BOOLEAN;


  SELECT disponible INTO v_disponible
  FROM libro WHERE id_libro = p_id_libro;


  IF v_disponible = TRUE THEN
    INSERT INTO prestamo (id_libro, id_usuario, fecha_prestamo, fecha_devolucion_esperada, estado)
    VALUES (p_id_libro, p_id_usuario, CURDATE(), DATE_ADD(CURDATE(), INTERVAL p_dias DAY), 'ACTIVO');


UPDATE libro SET disponible = FALSE WHERE id_libro = p_id_libro;

SELECT 'Pr\u00e9stamo registrado exitosamente' AS mensaje;

  ELSE
    SELECT 'El libro no est\u00e1 disponible para pr\u00e9stamo' AS mensaje;
  END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_multa`
--

CREATE TABLE `auditoria_multa` (
  `id` int(11) NOT NULL,
  `mensaje` varchar(200) DEFAULT NULL,
  `fecha` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_prestamo`
--

CREATE TABLE `auditoria_prestamo` (
  `id` int(11) NOT NULL,
  `id_prestamo` int(11) DEFAULT NULL,
  `estado_anterior` varchar(20) DEFAULT NULL,
  `estado_nuevo` varchar(20) DEFAULT NULL,
  `fecha` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `auditoria_prestamo`
--

INSERT INTO `auditoria_prestamo` (`id`, `id_prestamo`, `estado_anterior`, `estado_nuevo`, `fecha`) VALUES
(1, 21, 'ACTIVO', 'DEVUELTO', '2026-04-07 07:04:46'),
(2, 22, 'ACTIVO', 'DEVUELTO', '2026-04-07 07:06:05');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `autor`
--

CREATE TABLE `autor` (
  `id_autor` int(11) NOT NULL,
  `nombres` varchar(100) NOT NULL,
  `apellidos` varchar(100) NOT NULL,
  `nacionalidad` varchar(50) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `autor`
--

INSERT INTO `autor` (`id_autor`, `nombres`, `apellidos`, `nacionalidad`, `fecha_nacimiento`) VALUES
(1, 'Paulo', 'Coelho', 'Brasil', '1947-08-24'),
(2, 'Gabriel', 'Garcia Marquez', 'Colombia', '1927-03-06'),
(3, 'Julio', 'Cortazar\r\n', 'Argentina', '1914-08-26'),
(4, 'Isabel', 'Allende', 'Chile', '1942-08-02'),
(5, 'Jorge Luis', 'Borges', 'Argentina', '1899-08-24'),
(6, 'Mario', 'Vargas Llosa', 'Peru', '1936-03-28'),
(7, 'Octavio', 'Paz', 'Mexico', '1914-03-31'),
(8, 'Pablo', 'Neruda', 'Chile', '1904-07-12'),
(9, 'Carlos', 'Fuentes', 'Mexico', '1928-11-11'),
(10, 'Ruben', 'Dario\r\n', 'Nicaragua', '1867-01-18'),
(11, 'Laura', 'Restrepo', 'Colombia', '1950-01-13'),
(12, 'Tomas', 'Gonzalez\r\n', 'Colombia', '1950-11-15'),
(13, 'Piedad', 'Bonnett', 'Colombia', '1951-11-03'),
(14, 'Alvaro', 'Mutis', 'Colombia', '1923-08-25'),
(15, 'William', 'Ospina', 'Colombia', '1954-03-02'),
(16, 'Umberto', 'Eco', 'Italia', '1932-01-05'),
(17, 'George', 'Orwell', 'Reino Unido', '1903-06-25'),
(18, 'Franz', 'Kafka', 'Republica Checa', '1883-07-03'),
(19, 'Fyodor', 'Dostoevsky', 'Rusia', '1821-11-11'),
(20, 'Haruki', 'Murakami', 'Japon', '1949-01-12');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria`
--

CREATE TABLE `categoria` (
  `id_categoria` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `categoria`
--

INSERT INTO `categoria` (`id_categoria`, `nombre`, `descripcion`) VALUES
(1, 'Novela', 'Narrativa de ficcion extensa\r\n'),
(2, 'Literatura', 'Obras literarias clasicas y cotemporaneas\r\n'),
(3, 'Cuento', 'Narrativa corta'),
(4, 'Poesia', 'Obras en verso'),
(5, 'Ensayo', 'Obras de reflexion y analisis\r\n'),
(6, 'Ciencia Ficcion', 'Ficcion basada en ciencia y tecnologia\r\n'),
(7, 'Historia', 'Obras de analisis historico\r\n'),
(8, 'Filosofia', 'Relfexion filosofica y pensamiento critico'),
(9, 'Biologia\r\n', 'Ciencias de la vida'),
(10, 'Informatica', 'Tecnologia y programacion\r\n');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `editorial`
--

CREATE TABLE `editorial` (
  `id_editorial` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `pais` varchar(50) DEFAULT NULL,
  `sitio_web` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `editorial`
--

INSERT INTO `editorial` (`id_editorial`, `nombre`, `pais`, `sitio_web`) VALUES
(1, 'Planeta', 'España', 'https://planeta.es'),
(2, 'Sudamericana', 'Argentina', 'https://sudamericana.com'),
(3, 'HarperCollins', 'USA', 'https://harpercollins.com'),
(4, 'Catedra\r\n', 'España', 'https://catedra.com'),
(5, 'Norma', 'Colombia', 'https://norma.com'),
(6, 'Alfaguara', 'España', 'https://alfaguara.com'),
(7, 'Fondo de Cultura', 'Mexico', 'https://fondodeculturaeconomica.com'),
(8, 'Penguin Random', 'USA', 'https://penguinrandomhouse.com'),
(9, 'Tusquets', 'España', 'https://tusquetseditores.com'),
(10, 'Siglo XXI', 'Mexico', 'https://sigloxxieditores.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `libro`
--

CREATE TABLE `libro` (
  `id_libro` int(11) NOT NULL,
  `titulo` varchar(200) NOT NULL,
  `isbn` varchar(20) DEFAULT NULL,
  `anio_publicacion` year(4) DEFAULT NULL,
  `num_paginas` int(11) DEFAULT NULL CHECK (`num_paginas` > 0),
  `id_editorial` int(11) DEFAULT NULL,
  `id_categoria` int(11) DEFAULT NULL,
  `disponible` tinyint(1) DEFAULT 1,
  `imagen` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `libro`
--

INSERT INTO `libro` (`id_libro`, `titulo`, `isbn`, `anio_publicacion`, `num_paginas`, `id_editorial`, `id_categoria`, `disponible`, `imagen`) VALUES
(1, 'A orillas del rio Piedra me sente y llore', '978-0061122415', '1994', 208, 1, 1, 0, NULL),
(2, 'Cien Años de Soledad\r\n', '978-0307474728', '1967', 432, 2, 2, 0, NULL),
(3, 'El amor en los tiempos del Colera\r\n', '978-0307389732', '1985', 368, 2, 2, 1, NULL),
(4, 'El Alquimista', '978-0062315007', '1988', 197, 3, 1, 1, NULL),
(5, 'Rayuela', '978-8437604572', '1963', 635, 4, 2, 1, NULL),
(6, 'La ciudad y los perros', '978-8437601441', '1963', 400, 4, 1, 1, NULL),
(7, 'El laberinto de la soledad', '978-9681600273', '1950', 191, 7, 8, 1, NULL),
(8, 'Veinte poemas de amor', '978-8420412801', '1924', 128, 6, 4, 1, NULL),
(9, 'La muerte de Artemio Cruz', '978-9681600105', '1962', 312, 7, 2, 0, NULL),
(10, 'Azul...', '978-8420691312', '0000', 160, 6, 4, 0, NULL),
(11, 'Delirio', '978-9584512055', '2004', 320, 5, 1, 1, NULL),
(12, 'En la diestra de Dios Padre', '978-9582008031', '1945', 180, 5, 3, 1, NULL),
(13, 'Siempreviva', '978-9588120980', '1999', 210, 5, 4, 0, '1775649328880_siempreviva.jpg'),
(14, 'La nieve del almirante', '978-8420611792', '1986', 224, 6, 1, 1, NULL),
(15, 'En donde el viento da la vuelta', '978-9585455863', '2019', 280, 5, 1, 0, NULL),
(16, 'El nombre de la rosa', '978-8483109359', '1980', 560, 9, 2, 1, NULL),
(17, '1984', '978-8499890944', '1949', 328, 3, 6, 0, NULL),
(18, 'La metamorfosis', '978-8497405768', '1915', 128, 10, 2, 1, NULL),
(19, 'Crimen y castigo', '978-8466639544', '0000', 672, 8, 2, 0, NULL),
(20, 'Kafka en la orilla', '978-8483835043', '2002', 504, 9, 1, 0, NULL),
(21, 'El señor de los Anillos', '978-84-450-1853-8', '1954', 1400, 3, 6, 0, '1775649224713_el_se_or_de_los_anillos.jpg');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `libro_autor`
--

CREATE TABLE `libro_autor` (
  `id_libro` int(11) NOT NULL,
  `id_autor` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `libro_autor`
--

INSERT INTO `libro_autor` (`id_libro`, `id_autor`) VALUES
(1, 1),
(2, 2),
(3, 2),
(4, 1),
(5, 3),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `multa`
--

CREATE TABLE `multa` (
  `id_multa` int(11) NOT NULL,
  `id_prestamo` int(11) NOT NULL,
  `monto` decimal(10,2) DEFAULT NULL CHECK (`monto` > 0),
  `fecha` date NOT NULL,
  `fecha_pago` date DEFAULT NULL,
  `estado` enum('PENDIENTE','PAGADA') DEFAULT 'PENDIENTE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `multa`
--

INSERT INTO `multa` (`id_multa`, `id_prestamo`, `monto`, `fecha`, `fecha_pago`, `estado`) VALUES
(1, 4, 5000.00, '2025-12-16', NULL, 'PENDIENTE'),
(2, 5, 15000.00, '2025-12-18', NULL, 'PENDIENTE'),
(3, 7, 20000.00, '2025-12-28', NULL, 'PENDIENTE'),
(4, 11, 8000.00, '2025-11-30', '2025-12-05', 'PAGADA'),
(5, 12, 12000.00, '2025-11-28', NULL, 'PENDIENTE'),
(6, 16, 2000.00, '2025-12-26', '2025-12-30', 'PAGADA'),
(7, 18, 10000.00, '2026-01-07', NULL, 'PENDIENTE'),
(8, 1, 3000.00, '2026-01-13', NULL, 'PENDIENTE'),
(9, 2, 3000.00, '2026-01-14', NULL, 'PENDIENTE'),
(10, 9, 4000.00, '2026-01-10', NULL, 'PENDIENTE'),
(11, 10, 4000.00, '2026-01-11', NULL, 'PENDIENTE'),
(12, 13, 2500.00, '2026-01-15', '2026-04-06', 'PAGADA');

--
-- Disparadores `multa`
--
DELIMITER $$
CREATE TRIGGER `trg_auditoria_multa` AFTER INSERT ON `multa` FOR EACH ROW BEGIN
  INSERT INTO auditoria_multa (mensaje)
  VALUES (CONCAT('Multa de $', NEW.monto, ' generada para pru00e9stamo #', NEW.id_prestamo, ' - Estado: ', NEW.estado));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `prestamo`
--

CREATE TABLE `prestamo` (
  `id_prestamo` int(11) NOT NULL,
  `id_libro` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `fecha_prestamo` date NOT NULL,
  `fecha_devolucion_esperada` date NOT NULL,
  `fecha_devolucion_real` date DEFAULT NULL,
  `estado` enum('ACTIVO','DEVUELTO','VENCIDO') DEFAULT 'ACTIVO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `prestamo`
--

INSERT INTO `prestamo` (`id_prestamo`, `id_libro`, `id_usuario`, `fecha_prestamo`, `fecha_devolucion_esperada`, `fecha_devolucion_real`, `estado`) VALUES
(1, 1, 1, '2026-01-05', '2026-01-12', NULL, 'ACTIVO'),
(2, 2, 2, '2026-01-06', '2026-01-13', NULL, 'ACTIVO'),
(3, 3, 3, '2025-12-01', '2025-12-08', '2025-12-07', 'DEVUELTO'),
(4, 4, 4, '2025-12-05', '2025-12-12', '2025-12-15', 'DEVUELTO'),
(5, 5, 5, '2025-12-10', '2025-12-17', NULL, 'VENCIDO'),
(6, 6, 6, '2025-12-15', '2025-12-22', '2025-12-22', 'DEVUELTO'),
(7, 7, 7, '2025-12-20', '2025-12-27', NULL, 'VENCIDO'),
(8, 8, 8, '2025-12-22', '2025-12-29', '2025-12-28', 'DEVUELTO'),
(9, 9, 9, '2026-01-02', '2026-01-09', NULL, 'ACTIVO'),
(10, 10, 10, '2026-01-03', '2026-01-10', NULL, 'ACTIVO'),
(11, 11, 11, '2025-11-15', '2025-11-22', '2025-11-30', 'DEVUELTO'),
(12, 12, 12, '2025-11-20', '2025-11-27', NULL, 'VENCIDO'),
(13, 13, 13, '2026-01-07', '2026-01-14', NULL, 'ACTIVO'),
(14, 14, 14, '2025-12-28', '2026-01-04', '2026-01-03', 'DEVUELTO'),
(15, 15, 15, '2026-01-08', '2026-01-15', NULL, 'ACTIVO'),
(16, 16, 16, '2025-12-18', '2025-12-25', '2025-12-26', 'DEVUELTO'),
(17, 17, 17, '2026-01-04', '2026-01-11', NULL, 'ACTIVO'),
(18, 18, 18, '2025-12-30', '2026-01-06', NULL, 'VENCIDO'),
(19, 19, 19, '2026-01-09', '2026-01-16', NULL, 'ACTIVO'),
(20, 20, 20, '2026-01-10', '2026-01-17', NULL, 'ACTIVO'),
(21, 3, 1, '2026-04-07', '2026-04-14', '2026-04-07', 'DEVUELTO'),
(22, 3, 24, '2026-04-07', '2026-04-14', '2026-04-07', 'DEVUELTO'),
(23, 21, 25, '2026-04-08', '2026-04-15', NULL, 'ACTIVO');

--
-- Disparadores `prestamo`
--
DELIMITER $$
CREATE TRIGGER `trg_auditoria_prestamo` AFTER UPDATE ON `prestamo` FOR EACH ROW BEGIN
  IF OLD.estado <> NEW.estado THEN
    INSERT INTO auditoria_prestamo (id_prestamo, estado_anterior, estado_nuevo)
    VALUES (NEW.id_prestamo, OLD.estado, NEW.estado);
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `documento` varchar(20) NOT NULL,
  `nombres` varchar(100) NOT NULL,
  `apellidos` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `tipo_usuario` enum('ESTUDIANTE','DOCENTE','ADMIN') NOT NULL,
  `estado` enum('ACTIVO','INACTIVO') DEFAULT 'ACTIVO',
  `password` varchar(100) DEFAULT '1234'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usuario`, `documento`, `nombres`, `apellidos`, `email`, `telefono`, `tipo_usuario`, `estado`, `password`) VALUES
(1, '1001', 'Mateo', 'Gonzalez', 'pedro@mail.com', '3001111111', 'ESTUDIANTE', 'ACTIVO', '1234'),
(2, '1002', 'Valeria', 'Herrera', 'laura@mail.com', '3002222222', 'DOCENTE', 'ACTIVO', '1234'),
(3, '1003', 'Santiago', 'Mora', 'andres@mail.com', '3003333333', 'ESTUDIANTE', 'ACTIVO', '1234'),
(4, '1004', 'Daniela', 'Rios', 'camila@mail.com', '3004444444', 'ADMIN', 'ACTIVO', '1234'),
(5, '1005', 'Juliana', 'Cardona', 'sofia@mail.com', '3005555555', 'ESTUDIANTE', 'ACTIVO', '1234'),
(6, '1006', 'Ricardo', 'Palacios', 'carlos@mail.com', '3006666666', 'DOCENTE', 'ACTIVO', '1234'),
(7, '1007', 'Carolina', 'Velez', 'vale@mail.com', '3007777777', 'ESTUDIANTE', 'ACTIVO', '1234'),
(8, '1008', 'David', 'Ospina', 'miguel@mail.com', '3008888888', 'ESTUDIANTE', 'ACTIVO', '1234'),
(9, '1009', 'Monica', 'Guerrero', 'ana@mail.com', '3009999999', 'DOCENTE', 'ACTIVO', '1234'),
(10, '1010', 'Alejandro', 'Quintero', 'luis@mail.com', '3010000000', 'ESTUDIANTE', 'ACTIVO', '1234'),
(11, '1011', 'Luisa', 'Cifuentes', 'daniela@mail.com', '3011111111', 'ESTUDIANTE', 'ACTIVO', '1234'),
(12, '1012', 'Nicolas', 'Aguilar', 'sebas@mail.com', '3012222222', 'ESTUDIANTE', 'ACTIVO', '1234'),
(13, '1013', 'Adriana', 'Castano', 'paola@mail.com', '3013333333', 'DOCENTE', 'ACTIVO', '1234'),
(14, '1014', 'Mario', 'Betancourt', 'julian@mail.com', '3014444444', 'ESTUDIANTE', 'ACTIVO', '1234'),
(15, '1015', 'Marcela', 'Escobar', 'maria@mail.com', '3015555555', 'ESTUDIANTE', 'ACTIVO', '1234'),
(16, '1016', 'Andres', 'Acevedo', 'diego@mail.com', '3016666666', 'ESTUDIANTE', 'ACTIVO', '1234'),
(17, '1017', 'Gloria', 'Sanchez', 'natalia@mail.com', '3017777777', 'DOCENTE', 'ACTIVO', '1234'),
(18, '1018', 'Ivan', 'Cano', 'felipe@mail.com', '3018888888', 'ESTUDIANTE', 'ACTIVO', '1234'),
(19, '1019', 'Tatiana', 'Londono', 'isabella@mail.com', '3019999998', 'ESTUDIANTE', 'ACTIVO', '1234'),
(20, '1020', 'Jorge', 'Zapata', 'esteban@mail.com', '3020000000', 'ESTUDIANTE', 'ACTIVO', '1234'),
(21, '1057983040', 'Erika', 'Montoya', 'alejandro@gmail.com', '3124659879', 'ESTUDIANTE', 'ACTIVO', '1234'),
(22, '1057980598', 'Fabian Leonardo', 'Giraldo Molina', 'alejo@gmail.com', '3567431285', 'ESTUDIANTE', 'INACTIVO', '1234'),
(24, '1579863450', 'Catalina', 'Gaviria', 'juan@gmail.com', '35698564257', 'ESTUDIANTE', 'ACTIVO', '1234'),
(25, '1111', 'Hector', 'Mejia', 'andres@gmail.com', '3265748514', 'ESTUDIANTE', 'ACTIVO', '1234');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_libros_con_autores`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_libros_con_autores` (
`id_libro` int(11)
,`titulo` varchar(200)
,`isbn` varchar(20)
,`anio_publicacion` year(4)
,`autor` varchar(201)
,`categoria` varchar(100)
,`editorial` varchar(100)
,`disponible` tinyint(1)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_prestamos_activos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_prestamos_activos` (
`id_prestamo` int(11)
,`titulo_libro` varchar(200)
,`nombre_usuario` varchar(201)
,`tipo_usuario` enum('ESTUDIANTE','DOCENTE','ADMIN')
,`fecha_prestamo` date
,`fecha_devolucion_esperada` date
,`dias_retraso` int(7)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_total_multas_usuario`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_total_multas_usuario` (
`id_usuario` int(11)
,`nombre_usuario` varchar(201)
,`total_multas` bigint(21)
,`monto_total` decimal(32,2)
,`pendiente_pago` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_libros_con_autores`
--
DROP TABLE IF EXISTS `vista_libros_con_autores`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_libros_con_autores`  AS SELECT `l`.`id_libro` AS `id_libro`, `l`.`titulo` AS `titulo`, `l`.`isbn` AS `isbn`, `l`.`anio_publicacion` AS `anio_publicacion`, concat(`a`.`nombres`,' ',`a`.`apellidos`) AS `autor`, `c`.`nombre` AS `categoria`, `e`.`nombre` AS `editorial`, `l`.`disponible` AS `disponible` FROM ((((`libro` `l` join `libro_autor` `la` on(`la`.`id_libro` = `l`.`id_libro`)) join `autor` `a` on(`a`.`id_autor` = `la`.`id_autor`)) join `categoria` `c` on(`c`.`id_categoria` = `l`.`id_categoria`)) join `editorial` `e` on(`e`.`id_editorial` = `l`.`id_editorial`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_prestamos_activos`
--
DROP TABLE IF EXISTS `vista_prestamos_activos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_prestamos_activos`  AS SELECT `p`.`id_prestamo` AS `id_prestamo`, `l`.`titulo` AS `titulo_libro`, concat(`u`.`nombres`,' ',`u`.`apellidos`) AS `nombre_usuario`, `u`.`tipo_usuario` AS `tipo_usuario`, `p`.`fecha_prestamo` AS `fecha_prestamo`, `p`.`fecha_devolucion_esperada` AS `fecha_devolucion_esperada`, to_days(curdate()) - to_days(`p`.`fecha_devolucion_esperada`) AS `dias_retraso` FROM ((`prestamo` `p` join `libro` `l` on(`p`.`id_libro` = `l`.`id_libro`)) join `usuario` `u` on(`p`.`id_usuario` = `u`.`id_usuario`)) WHERE `p`.`estado` = 'ACTIVO' ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_total_multas_usuario`
--
DROP TABLE IF EXISTS `vista_total_multas_usuario`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_total_multas_usuario`  AS SELECT `u`.`id_usuario` AS `id_usuario`, concat(`u`.`nombres`,' ',`u`.`apellidos`) AS `nombre_usuario`, count(`m`.`id_multa`) AS `total_multas`, sum(`m`.`monto`) AS `monto_total`, sum(case when `m`.`estado` = 'PENDIENTE' then `m`.`monto` else 0 end) AS `pendiente_pago` FROM ((`usuario` `u` join `prestamo` `p` on(`p`.`id_usuario` = `u`.`id_usuario`)) join `multa` `m` on(`m`.`id_prestamo` = `p`.`id_prestamo`)) GROUP BY `u`.`id_usuario`, `u`.`nombres`, `u`.`apellidos` ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `auditoria_multa`
--
ALTER TABLE `auditoria_multa`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `auditoria_prestamo`
--
ALTER TABLE `auditoria_prestamo`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `autor`
--
ALTER TABLE `autor`
  ADD PRIMARY KEY (`id_autor`);

--
-- Indices de la tabla `categoria`
--
ALTER TABLE `categoria`
  ADD PRIMARY KEY (`id_categoria`),
  ADD UNIQUE KEY `nombre` (`nombre`);

--
-- Indices de la tabla `editorial`
--
ALTER TABLE `editorial`
  ADD PRIMARY KEY (`id_editorial`);

--
-- Indices de la tabla `libro`
--
ALTER TABLE `libro`
  ADD PRIMARY KEY (`id_libro`),
  ADD UNIQUE KEY `isbn` (`isbn`),
  ADD KEY `idx_libro_categoria` (`id_categoria`),
  ADD KEY `idx_libro_editorial` (`id_editorial`),
  ADD KEY `idx_libro_disponible` (`disponible`);

--
-- Indices de la tabla `libro_autor`
--
ALTER TABLE `libro_autor`
  ADD PRIMARY KEY (`id_libro`,`id_autor`),
  ADD KEY `id_autor` (`id_autor`);

--
-- Indices de la tabla `multa`
--
ALTER TABLE `multa`
  ADD PRIMARY KEY (`id_multa`),
  ADD KEY `idx_multa_prestamo` (`id_prestamo`);

--
-- Indices de la tabla `prestamo`
--
ALTER TABLE `prestamo`
  ADD PRIMARY KEY (`id_prestamo`),
  ADD KEY `idx_prestamo_usuario` (`id_usuario`),
  ADD KEY `idx_prestamo_libro` (`id_libro`),
  ADD KEY `idx_prestamo_estado` (`estado`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `documento` (`documento`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `auditoria_multa`
--
ALTER TABLE `auditoria_multa`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auditoria_prestamo`
--
ALTER TABLE `auditoria_prestamo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `autor`
--
ALTER TABLE `autor`
  MODIFY `id_autor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `categoria`
--
ALTER TABLE `categoria`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `editorial`
--
ALTER TABLE `editorial`
  MODIFY `id_editorial` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `libro`
--
ALTER TABLE `libro`
  MODIFY `id_libro` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT de la tabla `multa`
--
ALTER TABLE `multa`
  MODIFY `id_multa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `prestamo`
--
ALTER TABLE `prestamo`
  MODIFY `id_prestamo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `libro`
--
ALTER TABLE `libro`
  ADD CONSTRAINT `libro_ibfk_1` FOREIGN KEY (`id_editorial`) REFERENCES `editorial` (`id_editorial`),
  ADD CONSTRAINT `libro_ibfk_2` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`);

--
-- Filtros para la tabla `libro_autor`
--
ALTER TABLE `libro_autor`
  ADD CONSTRAINT `libro_autor_ibfk_1` FOREIGN KEY (`id_libro`) REFERENCES `libro` (`id_libro`) ON DELETE CASCADE,
  ADD CONSTRAINT `libro_autor_ibfk_2` FOREIGN KEY (`id_autor`) REFERENCES `autor` (`id_autor`) ON DELETE CASCADE;

--
-- Filtros para la tabla `multa`
--
ALTER TABLE `multa`
  ADD CONSTRAINT `multa_ibfk_1` FOREIGN KEY (`id_prestamo`) REFERENCES `prestamo` (`id_prestamo`);

--
-- Filtros para la tabla `prestamo`
--
ALTER TABLE `prestamo`
  ADD CONSTRAINT `prestamo_ibfk_1` FOREIGN KEY (`id_libro`) REFERENCES `libro` (`id_libro`),
  ADD CONSTRAINT `prestamo_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
