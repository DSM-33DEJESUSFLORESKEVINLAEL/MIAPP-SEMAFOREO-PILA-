const String tableUsers = '''
  CREATE TABLE IF NOT EXISTS users (  
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL
  );
''';

const String tableEmpresas = '''
  CREATE TABLE IF NOT EXISTS empresas (
    empresa INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL,
    desmontaje_inmediato INTEGER,
    desmontaje_prox_desde INTEGER,
    desmontaje_prox_hasta INTEGER,
    buenas_condiciones INTEGER
  );
''';

const String tableBases = '''
  CREATE TABLE IF NOT EXISTS bases (
    empresa INTEGER NOT NULL,
    base TEXT NOT NULL,
    serie TEXT,
    serie_compras TEXT,
    serie_economico TEXT,
    emp_cte INTEGER,
    cliente TEXT,
    lugar TEXT,
    grupo TEXT
  );
''';



const String tableMedida = '''
  CREATE TABLE IF NOT EXISTS medida (
    empresa INTEGER NOT NULL,
    medida TEXT NOT NULL,
    sincronizado INTEGER DEFAULT 0
  );
''';

const String tableMarca = '''
  CREATE TABLE IF NOT EXISTS marca (
    empresa INTEGER NOT NULL,
    marca TEXT NOT NULL UNIQUE,
    procedencia TEXT,
    sincronizado INTEGER DEFAULT 0
  );
''';

const String tableFallas = '''
 CREATE TABLE IF NOT EXISTS fallas (
    empresa INTEGER NOT NULL,
    falla TEXT PRIMARY KEY,
    descripcion TEXT,
    area TEXT,
    FOREIGN KEY (empresa) REFERENCES empresas(empresa) ON DELETE CASCADE
  );
''';

const String tableTipoUnidad = '''
 CREATE TABLE IF NOT EXISTS tipo_unidad (
    empresa INTEGER NOT NULL,
    tunidad TEXT PRIMARY KEY,
    FOREIGN KEY (empresa) REFERENCES empresas(empresa) ON DELETE CASCADE
  );
''';

const String tableRangoCarga= '''
  CREATE TABLE IF NOT EXISTS rango_carga (
    empresa INTEGER NOT NULL,
    rc TEXT PRIMARY KEY,
    descripcion TEXT,
    FOREIGN KEY (empresa) REFERENCES empresas(empresa) ON DELETE CASCADE
  );
''';

const String tableAccesosPermisos = '''
  CREATE TABLE IF NOT EXISTS accesos_permisos (
    empresa INTEGER NOT NULL,
    base TEXT NOT NULL,
    usuario TEXT NOT NULL,
    acceso TEXT NOT NULL,
    PRIMARY KEY (empresa, base, usuario),
    FOREIGN KEY (empresa) REFERENCES empresas(empresa) ON DELETE CASCADE,
    FOREIGN KEY (base) REFERENCES bases(base) ON DELETE CASCADE
  );
''';

const String tableMarcarenovado = '''
  CREATE TABLE IF NOT EXISTS marca_renovado (
    empresa INTEGER NOT NULL,
    marca TEXT NOT NULL,
    descripcion TEXT,
    FOREIGN KEY (empresa) REFERENCES empresas(empresa) ON DELETE CASCADE,
    FOREIGN KEY (marca) REFERENCES marca(marca) ON DELETE CASCADE
  );
''';

const String tableModelorenovado = '''
  CREATE TABLE IF NOT EXISTS modelo_renovado (
    empresa INTEGER NOT NULL,
    modelo TEXT NOT NULL,
    descripcion TEXT,
    FOREIGN KEY (empresa) REFERENCES empresas(empresa) ON DELETE CASCADE
  );
''';

const String tableUnidades = '''
  CREATE TABLE IF NOT EXISTS unidades (
    empresa INTEGER NOT NULL,
    base TEXT NOT NULL,
    folio TEXT NOT NULL,
    unidad TEXT PRIMARY KEY,
    tunidad TEXT,
    obs TEXT,
    status TEXT,
    ejes INTEGER,
    num_llantas INTEGER,
    FOREIGN KEY (empresa) REFERENCES empresas(empresa) ON DELETE CASCADE,
    FOREIGN KEY (base) REFERENCES bases(base) ON DELETE CASCADE,
    FOREIGN KEY (folio) REFERENCES sem_mstr(folio) ON DELETE CASCADE,
    FOREIGN KEY (tunidad) REFERENCES tipo_unidad(tunidad) ON DELETE SET NULL
  );
''';

const String tableAccesosUsuarios = '''
CREATE TABLE IF NOT EXISTS accesos_usuarios (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  usuario TEXT NOT NULL,
  nombre TEXT NOT NULL,
  psw TEXT NOT NULL,
  falta TEXT,
  fbaja TEXT,
  puesto TEXT,
  obs TEXT,
  empresa INTEGER NOT NULL,
  base TEXT NOT NULL
);
''';


const String tableSemMstr = '''
  CREATE TABLE IF NOT EXISTS sem_mstr (
    empresa INTEGER NOT NULL,
    base TEXT NOT NULL,
    folio TEXT NOT NULL,
    fecha TEXT NOT NULL,
    operador TEXT,
    num_semana INTEGER,
    num_mes INTEGER,
    nregistros INTEGER,
    sin_llanta INTEGER,
    cero INTEGER,
    desmontaje_inmediato INTEGER,
    desmontaje_proximo INTEGER,
    buenas_condiciones INTEGER,
    llantas_revisadas INTEGER,
    llantas_originales INTEGER,
    llantas_renovadas INTEGER,
    fsistema TEXT,
    nunidades INTEGER,
    nllantas INTEGER,
    nosem_unidades INTEGER,
    nosem_llantas INTEGER,
    cierre_operador TEXT,
    cierre_supervisor TEXT,
    cierre_empresa TEXT,
    fcierre_operador TEXT,
    fcierre_supervisor TEXT,
    fcierre_empresa TEXT,
    sincronizado INTEGER DEFAULT 0

  );
''';

const String tableSemDet = '''
  CREATE TABLE IF NOT EXISTS sem_det (
    empresa INTEGER NOT NULL,
    base TEXT NOT NULL,
    folio TEXT NOT NULL,
    usuario TEXT NOT NULL,
    reg INTEGER NOT NULL,
    unidad TEXT NOT NULL,
    tunidad TEXT,
    medida_direccion TEXT,
    medida_trasera TEXT,
    mm1 INTEGER,
    or1 INTEGER,
    obs1 TEXT,
    mm2 INTEGER,
    or2 INTEGER,
    obs2 TEXT,
    mm3 INTEGER,
    or3 INTEGER,
    obs3 TEXT,
    mm4 INTEGER,
    or4 INTEGER,
    obs4 TEXT,
    mm5 INTEGER,
    or5 INTEGER,
    obs5 TEXT,
    mm6 INTEGER,
    or6 INTEGER,
    obs6 TEXT,
    mm7 INTEGER,
    or7 INTEGER,
    obs7 TEXT,
    mm8 INTEGER,
    or8 INTEGER,
    obs8 TEXT,
    mm9 INTEGER,
    or9 INTEGER,
    obs9 TEXT,
    mm10 INTEGER,
    or10 INTEGER,
    obs10 TEXT,
    mm11 INTEGER,
    or11 INTEGER,
    obs11 TEXT,
    mm12 INTEGER,
    or12 INTEGER,
    obs12 TEXT,
    obs TEXT,
    sin_llanta INTEGER,
    cero INTEGER,
    retiro INTEGER,
    prox_retiro INTEGER,
    buenas INTEGER,
    originales INTEGER,
    renovadas INTEGER,
    num_llantas INTEGER,
    mm_promedio REAL,
    mm_suma REAL,
    fsistema TEXT,
    tmarca1 TEXT,
    tmarca2 TEXT,
    tmarca3 TEXT,
    tmarca4 TEXT,
    tmarca5 TEXT,
    tmarca6 TEXT,
    tmarca7 TEXT,
    tmarca8 TEXT,
    tmarca9 TEXT,
    tmarca10 TEXT,
    tmarca11 TEXT,
    tmarca12 TEXT,
    dot1 INTEGER,
    dot2 INTEGER,
    dot3 INTEGER,
    dot4 INTEGER,
    dot5 INTEGER,
    dot6 INTEGER,
    dot7 INTEGER,
    dot8 INTEGER,
    dot9 INTEGER,
    dot10 INTEGER,
    dot11 INTEGER,
    dot12 INTEGER,
    edo_unidad INTEGER,
    bit1 TEXT,
    bit2 TEXT,
    bit3 TEXT,
    bit4 TEXT,
    bit5 TEXT,
    bit6 TEXT,
    bit7 TEXT,
    bit8 TEXT,
    bit9 TEXT,
    bit10 TEXT,
    bit11 TEXT,
    bit12 TEXT,
    sincronizado INTEGER DEFAULT 0
  );
''';
 
 
const String tableDesMstr = '''
  CREATE TABLE IF NOT EXISTS desMstr (
    empresa INTEGER NOT NULL,
    base TEXT NOT NULL,
    folio TEXT NOT NULL,
    fecha TEXT NOT NULL,
    sis_medida TEXT,
    operador TEXT,
    num_semana INTEGER,
    num_mes INTEGER,
    nregistros INTEGER,
    fsistema TEXT,
    sincronizado INTEGER DEFAULT 0,
    PRIMARY KEY (empresa, base, folio),
    FOREIGN KEY (empresa) REFERENCES empresas(empresa) ON DELETE CASCADE,
    FOREIGN KEY (base) REFERENCES bases(base) ON DELETE CASCADE
  );
''';

const String tableDesDet = '''
  CREATE TABLE IF NOT EXISTS desdet (
    empresa INTEGER NOT NULL,
    base TEXT NOT NULL,
    folio TEXT NOT NULL,
    reg INTEGER NOT NULL,
    procedencia TEXT,
    sis_medida TEXT,
    operador TEXT,
    marca TEXT,
    modelo TEXT,
    medida TEXT,
    piso_remanente INTEGER,
    rango_carga TEXT,
    oriren INTEGER,
    marca_ren TEXT,
    modelo_ren TEXT,
    serie TEXT,
    dot TEXT,
    falla1 TEXT,
    falla2 TEXT,
    falla3 TEXT,
    falla4 TEXT,
    falla5 TEXT,
    anio INTEGER,
    fsistema TEXT,
    sincronizado INTEGER DEFAULT 0,
    PRIMARY KEY (FOLIO, REG)
  );
''';

