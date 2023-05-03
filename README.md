# bd2_project1_extendible_hashing_avl_tree

BD2 Project 1

### **Integrantes**
* Mario Rios Gamboa
* Luis Berrospi Rodriguez
* Angello Zuloaga Loo


## **Tabla de contenido**
- [bd2\_project1\_extendible\_hashing\_avl\_tree](#bd2_project1_extendible_hashing_avl_tree)
    - [**Integrantes**](#integrantes)
  - [**Tabla de contenido**](#tabla-de-contenido)
- [**Introducción**](#introducción)
  - [**Objetivo**](#objetivo)
  - [**Dominio de Datos**](#dominio-de-datos)
    - [**Dataset games**](#dataset-games)
    - [**Dataset movies**](#dataset-games)
- [**Técnicas Utilizadas**](#técnicas-utilizadas)
  - [**AVL File**](#avl-file)
    - [**Clase AVL**](#clase-avl)
      - [Uso](#uso)
    - [**Función Insert**](#función-insert)
      - [Uso](#uso-1)
    - [**Función Delete**](#función-delete)
      - [Uso](#uso-2)
    - [**Función Search**](#función-search)
      - [Uso](#uso-3)
    - [**Función Search Range**](#función-search-range)
      - [Uso](#uso-4)
  - [**Extendible Hash**](#extendible-hash)
    - [**Clase ExtendibleHash**](#clase-extendiblehash)
      - [Uso](#uso-5)
    - [**Función Insert**](#función-insert-1)
      - [Uso](#uso-6)
    - [**Función Delete**](#función-delete-1)
      - [Uso](#uso-7)
    - [**Función Search**](#función-search-1)
      - [Uso](#uso-8)
    - [**Función Search Range**](#función-search-range-1)
      - [Uso](#uso-9)
- [**Resultados**](#resultados)
  - [**AVL Tree**](#avl-tree)
    - [**Insert**](#insert)
    - [**Insert Memory Access**](#insert-memory-access)
    - [**Search**](#search)
    - [**Search Memory Access**](#search-memory-access)
  - [**Extendible Hash**](#extendible-hash-1)
    - [**Insert**](#insert-1)
    - [**Insert Memory Access**](#insert-memory-access-1)
    - [**Search**](#search-1)
    - [**Search Memory Access**](#search-memory-access-1)


# **Introducción**

## **Objetivo**
El objetivo del presente proyecto es desarrollar un Sistema Gestor de Base de Datos (SGBD) con sus principales funciones para el manejo de datos (insert, search, delete), utilizando técnicas estudiadas en clase y que sean implementadas de tal forma de que el sistema sea eficiente y amigable para el usuario.

## **Dominio de Datos**
En cuanto a los datos, se trabaja con los siguientes archivos en formato csv delimitados por el caracter '|'

### **Dataset games**
Presenta los siguientes campos:

| **Campo** | **Tipo** |
| --- | --- |
| publisher | `char[]` |
| game_title | `char[]` |
| price | `float` |

### **Dataset movies**
Presenta los siguientes campos:

| **Campo** | **Tipo** |
| --- | --- |
| id | `int` |
| primaryTitle | `char[]` |
| startYear | `char[]` |
| genres | `char[]` |

# **Técnicas Utilizadas**
## **AVL File**
Se implemento un AVL con las fucniones de insert, delete, search y search por rango para el manejo de los datos. Se utilizó una clase Template para poder manejar los tipos de datos que se pueden recibir, además se utilizaron *statments* de tipo `if constexpr` para poder mejorar el performance del programa al decidir en tiempo de compilación que código se ejecutará dependiendo del template.

### **Clase AVL**
Crea un nuevo objeto AVLTree que representa un árbol AVL implementado en memoria secundaria, utilizando el archivo especificado.
```c++
template <typename Record>
AvlTree(std::string &file_name);
```
- **Parámetros**
  - `file_name`: El nombre del archivo en el que se almacenarán los datos del árbol.
- **Valor de retorno**
  - Ninguno.
- **Precondiciones**
  - `file_name` debe ser una cadena de caracteres que represente un archivo existente y accesible.
- **Postcondiciones**
  - Se crea un nuevo objeto AVLTree que representa un árbol AVL implementado en memoria secundaria.
  - Si el archivo especificado ya existe, los datos previamente almacenados en él se cargarán en la estructura del árbol cuando se invoquen.
#### Uso
```c++
AVLTree avl("tree.dat");
```
Crea un nuevo objeto AVLTree que utiliza el archivo tree.dat para almacenar los datos del árbol.

### **Función Insert**
 Se encarga de insertar un registro de tipo `Record` en un árbol AVL implementado en memoria secundaria.
```c++
bool insert(Record &record)
```
- **Parámetros**
  - `record`: Referencia a un registro de tipo `Record` que se desea insertar en el árbol AVL.
- **Valor de retorno**
  - `true`:  si el registro fue insertado correctamente en el árbol AVL.
  - `false`: si el registro no pudo ser insertado en el árbol AVL.
- **Precondiciones**
  - El archivo binario que representa al árbol AVL debe existir en el sistema de archivos.
  - El registro record a insertar debe ser del mismo tipo que los registros almacenados en el árbol AVL.
- **Postcondiciones**
  - El registro record es insertado correctamente en el árbol AVL, tomando en cuenta la actualización de alturas, rotaciones y dobles rotaciones necesarias para su funcionamiento.
  - Si el árbol AVL estaba vacío, el registro record se convierte en la raíz del árbol.
#### Uso
```c++
GameRecord newGameRecord;
newGameRecord.publisher = "Nintendo";
newGameRecord.gameTitle = "The Legend of Zelda: Breath of the Wild";
newGameRecord.price = 59.99;

avl_tree.insert(newGameRecord);
```
Aquí creamos un nuevo registro de juego `newGameRecord` con el editor `Nintendo`, el título del juego `The Legend of Zelda: Breath of the Wild` y el precio de venta `59.99`. Luego, llamamos a la función insert en el árbol AVL instanciado `avl_tree`, pasando `newGameRecord` como el registro a insertar. La función devuelve `true` si la inserción fue exitosa.
### **Función Delete**
Elimina un elemento del árbol AVL, buscando el elemento con la clave `key`. Utiliza  un método de eliminación lógico.
```c++
template <typename T>
bool delete_item(T key);
```
- **Parámetros**
  - `T key`: clave del elemento a eliminar
- **Valor de retorno**
  - `true`: si el elemento fue eliminado exitosamente
  - `false`: si ocurrió un problema al eliminar el elemento.
- **Precondiciones**
  - El archivo donde se encuentra almacenado el árbol AVL debe existir en el sistema de archivos.
  - La clave `key` debe ser del mismo tipo que las claves de los registros almacenados en el árbol AVL.
- **Postcondiciones**
  - Si el elemento con clave key se encontraba en el árbol AVL, este será eliminado del archivo de manera lógica.
#### Uso
```c++
// Creamos un árbol AVL de enteros y agregamos algunos elementos
MemoryAVLTree<MovieRecord> tree("tree.dat");
// Eliminamos el elemento con clave 20
if (tree.delete_item(20)) {
    std::cout << "Elemento eliminado exitosamente\n";
} else {
    std::cout << "No se encontró el elemento a eliminar\n";
}
```
En este ejemplo, creamos un árbol AVL de `MovieRecords` utilizando el archivo `tree.dat`. Luego, llamamos a la función `delete_item` para eliminar el elemento con id 20. Si el elemento se encuentra en el árbol y es eliminado exitosamente, se imprimirá el mensaje "Elemento eliminado exitosamente". En caso contrario, se imprimirá "No se encontró el elemento a eliminar".

### **Función Search**
busca un registro en el árbol AVL implementado en memoria secundaria, utilizando el nombre como clave de búsqueda. Devuelve el registro correspondiente si se encuentra en el árbol, y si no se encuentra devuelve un registro vacío con altura -1.
```c++
template<typename T>
Record search_by_name(T name);
```
- **Parámetros**
  - `name`: Un valor de tipo genérico `T` que representa el nombre a buscar en el árbol AVL.
- **Valor de retorno**
  - `Record`: Devuelve un registro de tipo Record que representa el registro encontrado en el árbol AVL.
- **Precondiciones**
  - El archivo donde se encuentra almacenado el árbol AVL debe existir en el sistema de archivos.
  - La clave `name` debe ser del mismo tipo que las claves de los registros almacenados en el árbol AVL.
- **Postcondiciones**
  - Se devuelve el registro correspondiente si se encuentra en el árbol, y si no se encuentra devuelve un registro vacío con altura -1.
#### Uso
```c++
AVLTree<GameRecord> tree("game_index.dat");
// Buscamos el registro por su nombre
Record result = tree.search_by_name("Call of Duty: Modern Warfare");

// Imprimimos el registro encontrado
std::cout << "Registro encontrado: " << result.gameTitle << std::endl;
```
En este ejemplo, se crea una instancia de un árbol AVL un archivo "game_index.dat".. Finalmente, se busca el registro por su nombre utilizando la función `search_by_name` y se imprime en la consola el nombre del registro encontrado.

### **Función Search Range**
 Busca y devuelve un vector de registros de un árbol AVL implementado en memoria secundaria, cuyo nombre está entre dos valores `name1` y `name2`.
```c++
template<typename T>
std::vector<Record> search_by_name_range(T name1, T name2);
```
- **Parámetros**
  - `name1`: Valor de tipo genérico `T` que representa el nombre inicial del rango de búsqueda.
  - `name2`: Valor de tipo genérico `T` que representa el nombre final del rango de búsqueda.
- **Valor de retorno**
  - `std::vector<Record>`: Un vector de registros que cumplen con la condición de que su nombre está entre `name1` y `name2`.
- **Precondiciones**
  - El archivo donde se encuentra almacenado el árbol AVL debe existir en el sistema de archivos.
  - Los registros del árbol deben tener el campo key que se pueda comparar con los valores name1 y name2.
- **Postcondiciones**
  - Se devuelve un vector de registros que cumplen con la condición de que su nombre está entre `name1` y `name2`.
#### Uso
```c++
AvlTree<GameRecord> avlTree("games.dat");

char left[150] = "A";
char right[150] = "G";
auto result = avlTree.search_by_name_range(left, right);

for (auto &i : result) {
    std::cout << i.publisher << " "  << i.gameTitle <<" " <<i.publisher << std::endl;
}
```
En este ejemplo, se crea una instancia de un árbol AVL un archivo "games.dat". Luego, se busca un vector de registros cuyo nombre está entre "A" y "G" utilizando la función `search_by_name_range` y se imprime en la consola el nombre de los registros encontrados.


## **Extendible Hash**

### **Clase ExtendibleHash**
Descripcion del algoritmo
```c++
//firma de la funcióp
```
- **Parámetros**
  - `parametro`: descripción
- **Valor de retorno**
  - `tipo`: descripción
- **Precondiciones**
  - placeholder
- **Postcondiciones**
  - placeholder
#### Uso
```c++
//ejemplo de uso
```
resultado

### **Función Insert**
Descripcion del algoritmo
```c++
//firma de la funcióp
```
- **Parámetros**
  - `parametro`: descripción
- **Valor de retorno**
  - `tipo`: descripción
- **Precondiciones**
  - placeholder
- **Postcondiciones**
  - placeholder
#### Uso
```c++
//ejemplo de uso
```
resultado

### **Función Delete**
Descripcion del algoritmo
```c++
//firma de la funcióp
```
- **Parámetros**
  - `parametro`: descripción
- **Valor de retorno**
  - `tipo`: descripción
- **Precondiciones**
  - placeholder
- **Postcondiciones**
  - placeholder
#### Uso
```c++
//ejemplo de uso
```
resultado

### **Función Search**
Descripcion del algoritmo
```c++
//firma de la funcióp
```
- **Parámetros**
  - `parametro`: descripción
- **Valor de retorno**
  - `tipo`: descripción
- **Precondiciones**
  - placeholder
- **Postcondiciones**
  - placeholder
#### Uso
```c++
//ejemplo de uso
```
resultado

### **Función Search Range**
Descripcion del algoritmo
```c++
//firma de la funcióp
```
- **Parámetros**
  - `parametro`: descripción
- **Valor de retorno**
  - `tipo`: descripción
- **Precondiciones**
  - placeholder
- **Postcondiciones**
  - placeholder
#### Uso
```c++
//ejemplo de uso
```
resultado


# **Resultados**
Para los resultados se promedió el resultado de multiples pruebas para cada uno de los algoritmos, se utilizaron archivos con 52000 registros como mínimo. Se decidió tomar pruebas para tiempo de insert, número de accesos a memoria durante insert, tiempo de busqueda y numeró de accesos a memoria durante la busqueda cuando se llevaba a los breakpoints: 100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600 y 51200. Cabe mencionar que para cada uno de los dos csv de prueba (peliculas y videojuegos) se manejaron distintos tipos de keys a indexar (entero y string).

Se utilizó el cluster Khipu de la UTEC para realizar las pruebas. El mismo cuenta con un CPU Intel(R) Xeon(R) Gold 6230 CPU @ 2.10GHz. Se utilizó una cuenta educativa, por lo cual se contaba con:
- 72 cores del procesador
- 320 GB de memoria RAM
- 1.4 TB de almacenamiento

## **AVL Tree**
### **Insert**
<p float="left">
  <img src="./assets/avl_assets/games_running_time_insert.png" width="49%" />
  <img src="./assets/avl_assets/movies_running_time_insert.png" width="49%" /> 
</p>
Se puede observar como el tiempo de inserción para el árbol AVL bastante alto, llegando a tomar poco más de 0.25 segundos al momento de insertar cerca de 50000 registros. Por otro lado se puede observar la diferencia entre el tiempo de inserción de un árbol AVL que indexa un campo de tipo entero y uno que indexa un campo de tipo string. Se puede observar que el tiempo de inserción para el árbol que indexa un campo de tipo entero es menor que el tiempo de inserción para el árbol que indexa un campo de tipo string. Esto se debe a que la comparación de enteros es más rápida que la comparación de strings. 

### **Insert Memory Access**
<p float="left">
  <img src="./assets\avl_assets\games_secondary_memory_insert.png" width="49%" />
  <img src="assets\avl_assets\movies_secondary_memory_insert.png" width="49%" />
</p>
Se puede observar como el número de accesos a memoria para el árbol AVL es bastante alto, llegando a tomar cerca de 3000000 accesos a memoria al momento de insertar cerca de 50000 registros. Por otro lado se puede seguir observando la diferencia entre el número de accesos a memoria de un árbol AVL que indexa un campo de tipo entero y uno que indexa un campo de tipo string. La execiva cantidad de accesos a memoria se debe a que el árbol AVL es requiere de un gran número de comparaciones para poder insertar un nuevo registro, además de que el árbol AVL es un árbol balanceado, por lo que se requiere de un gran número de rotaciones para mantener el árbol balanceado.

### **Search**
<p float="left">
  <img src="./assets/avl_assets/games_running_time_search.png" width="49%" />
  <img src="./assets/avl_assets/movies_running_time_search.png" width="49%" />
</p>
Se puede observar como el tiempo de búsqueda para el árbol AVL cuenta con comportamiento logarítmico, estó tambien se ve reflejado en que ya no hay mucha diferencia entre realizar la busqueda entre tipos enteros y strings. Esto se debe a que el árbol AVL es un árbol balanceado (para 52000 registros solo necesitaria 16 comparaciones), la cantidad de comparaciones es bastante menor que el insert, por lo que deja de ser un factor determinante en el tiempo de búsqueda. 

### **Search Memory Access**
<p float="left">
  <img src="./assets/avl_assets/games_secondary_memory_search.png" width="49%" />
  <img src="./assets/avl_assets/movies_secondary_memory_search.png" width="49%" />
</p>
Se puede ver como el número de accesos a memoria para el árbol AVL se sigue comportando de manera logarítmica, al igual que el insert. De la misma manera, no hay mucha diferencia entre los tipos de la llave de busqueda.

## **Extendible Hash**

### **Insert**
<p float="left">
  <img src="assets\extendible_hash\games_running_time_insertion.png" width="49%" />
  <img src="assets\extendible_hash\movies_running_time_insertion.png" width="49%" />
</p>
Se puede observar como el tiempo de inserción para el hash extensible es bastante bajo, llegando a tomar poco más de 0.01 segundos al momento de insertar cerca de 50000 registros. Por otro lado se puede observar la diferencia entre el tiempo de inserción para un hash extensible que indexa un campo de tipo entero y uno que indexa un campo de tipo string. Se puede observar que el tiempo de inserción para el hash extensible que indexa un campo de tipo entero es menor que el tiempo de inserción para el hash extensible que indexa un campo de tipo string. Esto se debe a que la comparación de enteros es más rápida que la comparación de strings.

### **Insert Memory Access**
<p float="left">
  <img src="assets\extendible_hash\games_secondary_memory_access_insertion.png" width="49%" />
  <img src="assets\extendible_hash\movies_secondary_memory_access_insertion.png" width="49%" />
</p>
Se puede observar como el número de accesos a memoria para el hash extensible es bastante bajo, llegando a tomar cerca de 100000 accesos a memoria al momento de insertar cerca de 50000 registros. Por otro lado se puede seguir observando la diferencia entre el número de accesos a memoria de un hash extensible que indexa un campo de tipo entero y uno que indexa un campo de tipo string. La cantidad de accesos a memoria es bastante baja debido a que el hash extensible solo necesita de una comparación para poder insertar un nuevo registro, además de que el hash extensible no es un árbol balanceado, por lo que no se requiere de rotaciones para mantener el árbol balanceado.

### **Search**

<p float="left">
  <img src="assets\extendible_hash\games_running_time_search.png" width="49%" />
  <img src="assets\extendible_hash\movies_running_time_search.png" width="49%" />
</p>
Se puede observar como el tiempo de búsqueda para el hash extensible cuenta con comportamiento constante, estó tambien se ve reflejado en que ya no hay mucha diferencia entre realizar la busqueda entre tipos enteros y strings. Esto se debe a que el hash extensible no es un árbol balanceado, por lo que no se requiere de rotaciones para mantener el árbol balanceado.

### **Search Memory Access**
<p float="left">
  <img src="assets\extendible_hash\games_secondary_memory_access_search.png" width="49%" />
  <img src="assets\extendible_hash\movies_secondary_memory_access_search.png" width="49%" />
</p>
Se puede ver como el número de accesos a memoria para el hash extensible se sigue comportando de manera constante, al igual que el search. De la misma manera, no hay mucha diferencia entre los tipos de la llave de busqueda.
