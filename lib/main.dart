import 'package:flutter/material.dart' hide Table;
import 'dart:io';
import 'package:sqlparser/sqlparser.dart'
    show
        AnalysisContext,
        BasicType,
        BetweenExpression,
        BinaryExpression,
        DeleteStatement,
        ExpressionResultColumn,
        InsertStatement,
        NumericLiteral,
        Reference,
        ResolvedType,
        SelectStatement,
        SqlEngine,
        StarResultColumn,
        StringLiteral,
        Table,
        TableColumn,
        TableReference,
        ValuesSource;
import 'package:tuple/tuple.dart';

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
          content: Column(
        children: const [
          Text('Exito'),
          Text('La sentencia se ejecuto correctamente'),
        ],
      ));
    },
  );
}

void showFailureDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
          content: Column(
        children: [
          const Text('Error'),
          const Text('La sentencia no se ejecuto correctamente'),
        ],
      ));
    },
  );
}

late String baseFolder;

late String compiler;

// main with arguments
void main() {
  baseFolder = const String.fromEnvironment('BASEFOLDER');
  compiler = const String.fromEnvironment('COMPILER');
  if (baseFolder.isEmpty) {
    print('BASEFOLDER environment variable is not set');
    exit(1);
  }
  if (compiler.isEmpty) {
    print('COMPILER environment variable is not set');
    exit(1);
  }
  runApp(const MyApp());
}

class GamesStruct {
  final TableColumn publisher = TableColumn(
    'publisher',
    const ResolvedType(type: BasicType.text, nullable: false),
  );
  final TableColumn gameTitle = TableColumn(
    'gameTitle',
    const ResolvedType(type: BasicType.text, nullable: false),
  );
  final TableColumn price = TableColumn(
    'price',
    const ResolvedType(type: BasicType.real, nullable: false),
  );
  final TableColumn deleted = TableColumn(
    'deleted',
    isGenerated: true,
    const ResolvedType(type: BasicType.int, nullable: false),
  );

  final String tableName = 'games';

  final String dataset = 'games.csv';

  Table toTable(String customTableName) {
    return Table(
      name: customTableName,
      resolvedColumns: [
        publisher,
        gameTitle,
        price,
        deleted,
      ],
    );
  }
}

class MoviesStruct {
  final TableColumn id = TableColumn(
    'id',
    const ResolvedType(type: BasicType.int, nullable: false),
  );
  final TableColumn primaryTitle = TableColumn(
    'primaryTitle',
    const ResolvedType(type: BasicType.text, nullable: false),
  );
  final TableColumn year = TableColumn(
    'year',
    const ResolvedType(type: BasicType.text, nullable: false),
  );
  final TableColumn genres = TableColumn(
    'genres',
    const ResolvedType(type: BasicType.text, nullable: false),
  );
  final TableColumn deleted = TableColumn(
    'deleted',
    isGenerated: true,
    const ResolvedType(type: BasicType.int, nullable: false),
  );

  final String tableName = 'movies';

  final String dataset = 'movies.csv';

  Table toTable(String customTableName) {
    return Table(
      name: customTableName,
      resolvedColumns: [
        id,
        primaryTitle,
        year,
        genres,
        deleted,
      ],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title:
          'Base de Datos II - Proyecto 1 - Rios Gamboa, Berrospi Rodriguez y Angello Zuloaga',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
          title:
              'Base de Datos II - Proyecto 1 - Rios Gamboa, Berrospi Rodriguez y Angello Zuloaga'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;
  final dataStructureItems = [
    'extendible_hashing',
    'avl_tree',
  ];
  final datasets = [
    'movies.csv',
    'games.csv',
  ];

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _sqlSentence = TextEditingController();

  // each tableName with a TableObject and its Data Structure Type
  final tablesCreatedWithDataStructure =
      <String, Tuple3<Table, String, String>>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Column(
              children: const <Widget>[
                SizedBox(height: 30),
                Text(
                  'Estructuras de datos implementadas',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Extendible Hashing Tree',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'AVL Tree',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
            Expanded(
                child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Tablas creadas:',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...tablesCreatedWithDataStructure.entries
                      .map((e) => Text(
                            '${e.key} - ${e.value.item2} - ${e.value.item3}',
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ))
                      .toList(),
                  const SizedBox(height: 50),
                  TextField(
                    minLines: 4,
                    maxLines: 5,
                    controller: _sqlSentence,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'SQL Sentence',
                    ),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            onPressed(context, _sqlSentence, widget.datasets,
                                widget.dataStructureItems);
                          },
                          child: const Text('Execute'),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            final result = Process.runSync('$compiler', [
                              '${baseFolder}src/extendible_hashing_games.h',
                              '${baseFolder}src/extendible_hashing_movies.h',
                              '${baseFolder}src/avl_tree.h',
                              '${baseFolder}src/main.cpp',
                              '-o',
                              '${baseFolder}io/main'
                            ]);

                            if (result.exitCode != 0) {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text('Error'),
                                        content: Text(result.stderr as String),
                                      ));
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text('Success'),
                                        content: Text(
                                            "${result.stdout as String}\n${result.stderr as String}"),
                                      ));
                            }
                          },
                          child: const Text('Compile'),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            final dir = Directory('${baseFolder}/out');
                            dir.listSync().forEach((element) {
                              if (element is File) {
                                element.deleteSync();
                              }
                            });

                            // clean tables

                            showDialog(
                                context: context,
                                builder: (context) => const AlertDialog(
                                      title: Text('Success'),
                                      content: Text('Cleanup done'),
                                    ));

                            setState(() {
                              tablesCreatedWithDataStructure.clear();
                            });
                          },
                          child: const Text('Cleanup'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void isDeleteCallback(AnalysisContext result, BuildContext context) {
    final delete = result.root as DeleteStatement;
    final table = delete.from.tableName;
    final dataset = tablesCreatedWithDataStructure[table]!.item3;
    final dataStructure = tablesCreatedWithDataStructure[table]!.item2;
    final where = delete.where as BinaryExpression;
    final left = where.left as Reference;
    if (dataset == MoviesStruct().dataset) {
      if (left.columnName != MoviesStruct().id.name) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Column(
              children: const [
                Text('Errores'),
                Text('Campo que no sea id no es valido'),
              ],
            ));
          },
        );
        return;
      }
      final right = where.right as NumericLiteral;

      final tableName = table;
      final id = right.value.toInt();

      final result = Process.runSync('$baseFolder/io/main', [
        baseFolder,
        dataStructure,
        'delete',
        table,
        dataset,
        id.toString(),
      ]);

      if (result.exitCode != 0) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Column(
              children: const [
                Text('Errores'),
                Text('Error al eliminar el registro'),
              ],
            ));
          },
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Column(
            children: [
              const Text('Exit'),
              Text(result.stdout as String),
            ],
          ));
        },
      );
      return;
    }
    if (dataset == GamesStruct().dataset) {
      if (left.columnName != GamesStruct().gameTitle.name) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Column(
              children: const [
                Text('Errores'),
                Text('Campo que no sea gameTitle no es valido'),
              ],
            ));
          },
        );
        return;
      }
      final right = where.right as StringLiteral;

      final tableName = table;
      final gameTitle = right.value;

      final result = Process.runSync('$baseFolder/io/main', [
        baseFolder,
        dataStructure,
        'delete',
        table,
        dataset,
        gameTitle,
      ]);

      if (result.exitCode != 0) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Column(
              children: const [
                Text('Errores'),
                Text('Error al eliminar el registro'),
              ],
            ));
          },
        );
        return;
      }
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Column(
            children: [
              const Text('Exit'),
              Text(result.stdout as String),
            ],
          ));
        },
      );
      return;
    }
  }

  void isInsertCallback(AnalysisContext result, BuildContext context) {
    final insert = result.root as InsertStatement;
    final table = insert.table.tableName;
    final dataset = tablesCreatedWithDataStructure[table]!.item3;
    final dataStructure = tablesCreatedWithDataStructure[table]!.item2;
    final targetColumn = insert.targetColumns.map((e) => e.columnName).toList();
    if (dataset == MoviesStruct().dataset) {
      if (targetColumn.length != 4) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Column(
              children: const [
                Text('Errores'),
                Text('Debes incluir los 3 campos'),
              ],
            ));
          },
        );
        return;
      }
      final values = insert.source as ValuesSource;
      final valuesList = values.values.map((e) {
        return e.expressions.map((e) {
          if (e is NumericLiteral) {
            return e.value;
          } else if (e is StringLiteral) {
            return e.value;
          } else {
            return e.toString();
          }
        }).toList();
      }).toList()[0];
      final idIndex = targetColumn.indexOf(MoviesStruct().id.name);
      final id = valuesList[idIndex] as int;

      final primaryTitleIndex =
          targetColumn.indexOf(MoviesStruct().primaryTitle.name);
      final primaryTitle = valuesList[primaryTitleIndex] as String;

      final yearIndex = targetColumn.indexOf(MoviesStruct().year.name);
      final year = valuesList[yearIndex] as String;

      final genresIndex = targetColumn.indexOf(MoviesStruct().genres.name);
      final genres = valuesList[genresIndex] as String;

      final result = Process.runSync('$baseFolder/io/main', [
        baseFolder,
        dataStructure,
        'insert',
        table,
        dataset,
        id.toString(),
        primaryTitle,
        year,
        genres,
        primaryTitle,
        year.toString(),
        genres
      ]);

      if (result.exitCode != 0) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Column(
              children: const [
                Text('Errores'),
                Text('No se pudo insertar el registro'),
              ],
            ));
          },
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Column(
            children: [
              const Text('Exit'),
              Text(result.stdout as String),
            ],
          ));
        },
      );
      // validate values
    }
    if (dataset == GamesStruct().dataset) {
      if (targetColumn.length != 3) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Column(
              children: const [
                Text('Errores'),
                Text('Debes incluir los 3 campos'),
              ],
            ));
          },
        );
        return;
      }
      final values = insert.source as ValuesSource;
      final valuesList = values.values.map((e) {
        return e.expressions.map((e) {
          if (e is NumericLiteral) {
            return e.value;
          } else if (e is StringLiteral) {
            return e.value;
          } else {
            return e.toString();
          }
        }).toList();
      }).toList();

      final publisherIndex = targetColumn.indexOf(GamesStruct().publisher.name);
      final gameTitleIndex = targetColumn.indexOf(GamesStruct().gameTitle.name);
      final priceIndex = targetColumn.indexOf(GamesStruct().price.name);

      final publisher = valuesList[0][publisherIndex] as String;
      final gameTitle = valuesList[0][gameTitleIndex] as String;
      final price = valuesList[0][priceIndex] as double;

      final result = Process.runSync('$baseFolder/io/main', [
        baseFolder,
        dataStructure,
        'insert',
        table,
        dataset,
        publisher,
        gameTitle,
        price.toString(),
      ]);

      if (result.exitCode != 0) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Column(
              children: const [
                Text('Errores'),
                Text('No se pudo insertar el registro'),
              ],
            ));
          },
        );
        return;
      }
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Column(
            children: [
              const Text('Exit'),
              Text(result.stdout as String),
            ],
          ));
        },
      );
    }
  }

  void isSelectCallback(AnalysisContext result, BuildContext context) {
    final select = result.root as SelectStatement;
    final table = (select.from as TableReference).tableName;
    final dataset = tablesCreatedWithDataStructure[table]!.item3;
    final dataStructure = tablesCreatedWithDataStructure[table]!.item2;
    if (select.where is! BinaryExpression) {
      // it means a between
      final between = select.where as BetweenExpression;
      final check = between.check as Reference;
      if (dataset == MoviesStruct().dataset) {
        if (check.columnName != MoviesStruct().id.name) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  content: Column(
                children: const [
                  Text('Errores'),
                  Text('Campo que no sea id no es valido'),
                ],
              ));
            },
          );
          return;
        }
        final lower = between.lower as NumericLiteral;
        final upper = between.upper as NumericLiteral;
        final List<String> columnNames = [];
        if (select.columns[0] is StarResultColumn) {
          columnNames.addAll([
            MoviesStruct().id.name,
            MoviesStruct().year.name,
            MoviesStruct().genres.name,
            MoviesStruct().primaryTitle.name,
          ]);
        } else {
          columnNames.addAll(select.columns
              .map((e) =>
                  ((e as ExpressionResultColumn).expression as Reference)
                      .columnName)
              .toList());
        }

        final result = Process.runSync('$baseFolder/io/main', [
          baseFolder,
          dataStructure,
          'rangeSelect',
          table,
          dataset,
          lower.value.toString(),
          upper.value.toString(),
          columnNames.length.toString(),
          ...columnNames,
        ]);

        if (result.exitCode != 0) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  content: Column(
                children: const [
                  Text('Errores'),
                  Text('No se pudo realizar la consulta'),
                ],
              ));
            },
          );
          return;
        }

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Column(
              children: [
                const Text('Exit'),
                Text(result.stdout as String),
              ],
            ));
          },
        );
        return;

      }
      if (dataset == GamesStruct().dataset) {
        if (check.columnName != GamesStruct().gameTitle.name) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  content: Column(
                children: const [
                  Text('Errores'),
                  Text('Campo que no sea gameTitle no es valido'),
                ],
              ));
            },
          );
          return;
        }

        final lower = between.lower as StringLiteral;
        final upper = between.upper as StringLiteral;
        final List<String> columnNames = [];
        if (select.columns[0] is StarResultColumn) {
          columnNames.addAll([
            GamesStruct().publisher.name,
            GamesStruct().price.name,
            GamesStruct().gameTitle.name,
          ]);
        } else {
          columnNames.addAll(select.columns
              .map((e) =>
                  ((e as ExpressionResultColumn).expression as Reference)
                      .columnName)
              .toList());
        }

        final result = Process.runSync('$baseFolder/io/main', [
          baseFolder,
          dataStructure,
          'rangeSelect',
          table,
          dataset,
          lower.value,
          upper.value,
          columnNames.length.toString(),
          ...columnNames,
        ]);

        if (result.exitCode != 0) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  content: Column(
                children: const [
                  Text('Errores'),
                  Text('No se pudo realizar la consulta'),
                ],
              ));
            },
          );
          return;
        }

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Column(
              children: [
                const Text('Exit'),
                Text(result.stdout as String),
              ],
            ));
          },
        );
        return;
      }
      return;
    }
    final where = select.where as BinaryExpression;
    final left = where.left as Reference;

    if (dataset == MoviesStruct().dataset) {
      if (left.columnName != MoviesStruct().id.name) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Column(
              children: const [
                Text('Errores'),
                Text('Campo que no sea id no es valido'),
              ],
            ));
          },
        );
        return;
      }
      final right = where.right as NumericLiteral;

      final List<String> columnNames = [];
      if (select.columns[0] is StarResultColumn) {
        columnNames.addAll([
          MoviesStruct().id.name,
          MoviesStruct().year.name,
          MoviesStruct().genres.name,
          MoviesStruct().primaryTitle.name,
        ]);
      } else {
        columnNames.addAll(select.columns
            .map((e) => ((e as ExpressionResultColumn).expression as Reference)
                .columnName)
            .toList());
      }

      final tableName = table;
      final id = right.value.toInt();

      final result = Process.runSync('$baseFolder/io/main', [
        baseFolder,
        dataStructure,
        'select',
        tableName,
        dataset,
        id.toString(),
        columnNames.length.toString(),
        ...columnNames,
      ]);

      if (result.exitCode != 0) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Column(
              children: const [
                Text('Errores'),
                Text('No se pudo seleccionar el registro'),
              ],
            ));
          },
        );
        return;
      }
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Column(
            children: [
              const Text('Exit'),
              Text(result.stdout as String),
            ],
          ));
        },
      );
      return;
    }
    if (dataset == GamesStruct().dataset) {
      if (left.columnName != GamesStruct().gameTitle.name) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Column(
              children: const [
                Text('Errores'),
                Text('Campo que no sea gameTitle no es valido'),
              ],
            ));
          },
        );
        return;
      }
      final right = where.right as StringLiteral;

      final List<String> columnNames = [];
      if (select.columns[0] is StarResultColumn) {
        columnNames.addAll([
          GamesStruct().publisher.name,
          GamesStruct().price.name,
          GamesStruct().gameTitle.name,
        ]);
      } else {
        columnNames.addAll(select.columns
            .map((e) => ((e as ExpressionResultColumn).expression as Reference)
                .columnName)
            .toList());
      }

      final tableName = table;
      final filter = right.value;

      final result = Process.runSync('$baseFolder/io/main', [
        baseFolder,
        dataStructure,
        'select',
        tableName,
        dataset,
        filter,
        columnNames.length.toString(),
        ...columnNames,
      ]);

      if (result.exitCode != 0) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Column(
              children: const [
                Text('Errores'),
                Text('No se pudo insertar el registro'),
              ],
            ));
          },
        );
        return;
      }
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Column(
            children: [
              const Text('Exit'),
              Text(result.stdout as String),
            ],
          ));
        },
      );
    }
  }

  void isCreateCallback(BuildContext context, List<String> splitted,
      List<String> datasets, List<String> dataStructures) {
    try {
      final tableName = splitted[2];
      final dataset = splitted[4];
      if (!datasets.contains(dataset)) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Column(
              children: const [
                Text('Errores'),
                Text('Dataset no valido'),
              ],
            ));
          },
        );
        return;
      }
      final dataStructure = splitted[6];

      if (!dataStructures.contains(dataStructure)) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Column(
              children: const [
                Text('Errores'),
                Text('Estructura de datos no valida'),
              ],
            ));
          },
        );
        return;
      }

      var limit = splitted[8];

      if (limit.endsWith(';')) {
        limit = limit.substring(0, limit.length - 1);
      }

      final result = Process.runSync('$baseFolder/io/main',
          [baseFolder, dataStructure, 'seed', tableName, dataset, limit]);

      if (result.exitCode != 0) {
        showFailureDialog(context);
        return;
      }

      showSuccessDialog(context);
      setState(() {
        if (dataset == "movies.csv") {
          tablesCreatedWithDataStructure[tableName] =
              Tuple3(MoviesStruct().toTable(tableName), dataStructure, dataset);
        }
        if (dataset == "games.csv") {
          tablesCreatedWithDataStructure[tableName] =
              Tuple3(GamesStruct().toTable(tableName), dataStructure, dataset);
        }
      });
      return;
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Column(
            children: const [
              Text('Errores'),
              Text('Error inesperado'),
            ],
          ));
        },
      );
      return;
    }
  }

  void onPressed(BuildContext context, TextEditingController _sqlSentence,
      List<String> datasets, List<String> dataStructures) {
    // if (_sqlSentence.text != )
    if (_sqlSentence.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Column(
            children: const [
              Text('Errores'),
              Text('Error inesperado'),
            ],
          ));
        },
      );
      return;
    }

    final splitted = _sqlSentence.text.split(' ');
    final firstWord = splitted[0].toLowerCase();

    if (firstWord == 'create') {
      isCreateCallback(context, splitted, datasets, dataStructures);
      return;
    }

    final engine = SqlEngine();
    // iterate over tables
    tablesCreatedWithDataStructure.forEach((key, value) {
      engine.registerTable(value.item1);
    });
    // engine.registerTable(MoviesStruct().toTable());
    // engine.registerTable(GamesStruct().toTable());
    List<String> errors;

    AnalysisContext? result;
    try {
      result = engine.analyze(_sqlSentence.text);
      errors = result.errors.map((e) {
        final msgSpan = e.span;
        if (msgSpan != null) {
          return msgSpan.message(e.message ?? e.type.toString(), color: false);
        } else {
          return 'Error: $e.type: $e.message at $e.source';
        }
      }).toList();
    } catch (e) {
      errors = [e.toString()];
    }

    if (errors.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Column(
            children: [
              const Text('Errores'),
              ...errors.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    e,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }).toList(),
            ],
          ));
        },
      );
      return;
    }

    bool isInsert = result!.root is InsertStatement;
    bool isDelete = result.root is DeleteStatement;
    bool isSelect = result.root is SelectStatement;

    if (isInsert) {
      isInsertCallback(result, context);
    } else if (isDelete) {
      isDeleteCallback(result, context);
    } else if (isSelect) {
      isSelectCallback(result, context);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Column(
            children: const [
              Text('Errores'),
              Text('Solo se permiten create, select, insert y delete'),
            ],
          ));
        },
      );
    }
  }
}
