#include "extendible_hashing_movies.h"
#include "extendible_hashing_games.h"

void cleanUp(const string &dataFileName, const string &indexFileName)
{
    fstream dataFile(dataFileName, ios::out | ios::trunc | ios::binary);
    fstream indexFile(indexFileName, ios::out | ios::trunc | ios::binary);
    dataFile.close();
    indexFile.close();
}

int main(int argc, char *argv[])
{
    string baseFolder = argv[1];
    string moviesDatasetFileName = baseFolder + "data/movies.csv";
    string gamesDatasetFileName = baseFolder + "data/games.csv";
    string inputFile = baseFolder + "io/input.txt";
    string outputFile = baseFolder + "io/output.txt";

    // extendible_hashing or avl_tree
    string dataStructure = argv[2];
    // insert, search, delete, seed
    string action = argv[3];
    string tableName = argv[4];

    string dataFileName = baseFolder + "out/" + tableName + "_data.out";
    string indexFileName = baseFolder + "out/" + tableName + "_index.out";
    string nodesFileName = baseFolder + "out/" + tableName + "_nodes.out";

    string datasetFileName = argv[5];

    if (action == "seed")
    {
        int maxValues = stoi(argv[6]);

        if (datasetFileName == "movies.csv" && dataStructure == "extendible_hashing")
        {
            fstream dataFile(dataFileName, ios::out | ios::trunc | ios::binary);
            fstream indexFile(indexFileName, ios::out | ios::trunc | ios::binary);
            dataFile.close();
            indexFile.close();
            ExtendibleHashingMovies(indexFileName, dataFileName).seed(maxValues, moviesDatasetFileName);
        }
        if (datasetFileName == "games.csv" && dataStructure == "extendible_hashing")
        {
            fstream dataFile(dataFileName, ios::out | ios::trunc | ios::binary);
            fstream indexFile(indexFileName, ios::out | ios::trunc | ios::binary);
            dataFile.close();
            indexFile.close();
            ExtendibleHashingGames(indexFileName, dataFileName).seed(maxValues, gamesDatasetFileName);
        }
        return 0;
    }

    if (action == "insert")
    {
        if (datasetFileName == "movies.csv" && dataStructure == "extendible_hashing")
        {
            RecordMovies record{};
            int id = stoi(argv[6]);
            record.id = id;
            string primaryTitle = argv[7];
            strcpy(record.primaryTitle, primaryTitle.c_str());
            string year = argv[8];
            strcpy(record.year, year.c_str());
            string genres = argv[9];
            strcpy(record.genres, genres.c_str());

            bool resultAdd = ExtendibleHashingMovies(indexFileName, dataFileName).add(record);

            if (resultAdd)
            {
                cout << "Registro se insertó correctamente" << endl;
            }
            else
            {
                cout << "Registro no se pudo insertar" << endl;
            }
        }
        if (datasetFileName == "games.csv" && dataStructure == "extendible_hashing")
        {
            RecordGames record{};
            string publisher = argv[6];
            strcpy(record.publisher, publisher.c_str());
            string gameTitle = argv[7];
            strcpy(record.gameTitle, gameTitle.c_str());
            float price = stof(argv[8]);
            record.price = price;

            bool resultAdd = ExtendibleHashingGames(indexFileName, dataFileName).add(record);

            if (resultAdd)
            {
                cout << "Registro se insertó correctamente" << endl;
            }
            else
            {
                cout << "Registro no se pudo insertar" << endl;
            }
        }
    }

    if (action == "select")
    {
        if (datasetFileName == "movies.csv" && dataStructure == "extendible_hashing")
        {
            int id = stoi(argv[6]);
            int columnsAmount = stoi(argv[7]);
            vector<string> columns;
            for (int i = 0; i < columnsAmount; i++)
            {
                columns.push_back(argv[8 + i]);
            }

            auto resultSearch = ExtendibleHashingMovies(indexFileName, dataFileName).search(id);

            if (HAS_RECORD_VALUE(resultSearch))
            {
                auto record = GET_RECORD_VALUE_MOVIES(resultSearch);
                for (auto column : columns)
                {
                    if (column == "id")
                    {
                        cout << "id: " << record.id << endl;
                    }
                    if (column == "primaryTitle")
                    {
                        string primaryTitle = string(record.primaryTitle, sizeof(record.primaryTitle));
                        while (primaryTitle.back() == '\0')
                        {
                            primaryTitle.pop_back();
                        }
                        cout << "primaryTitle: " << primaryTitle << endl;
                    }
                    if (column == "year")
                    {
                        string year = string(record.year, sizeof(record.year));
                        while (year.back() == '\0')
                        {
                            year.pop_back();
                        }
                        cout << "year: " << year << endl;
                    }
                    if (column == "genres")
                    {
                        string genres = string(record.genres, sizeof(record.genres));
                        while (genres.back() == '\0')
                        {
                            genres.pop_back();
                        }
                        cout << "genres: " << genres << endl;
                    }
                }
            }
            else
            {
                cout << "Registro no se pudo encontrar" << endl;
            }
        }
        if (datasetFileName == "games.csv" && dataStructure == "extendible_hashing")
        {
            string gameTitlestr = argv[6];
            int columnsAmount = stoi(argv[7]);
            vector<string> columns;
            for (int i = 0; i < columnsAmount; i++)
            {
                columns.push_back(argv[8 + i]);
            }

            char gameTitle[TITLE_GAME_SIZE];
            strcpy(gameTitle, gameTitlestr.c_str());

            auto resultSearch = ExtendibleHashingGames(indexFileName, dataFileName).search(gameTitle);

            if (HAS_RECORD_VALUE(resultSearch))
            {
                auto record = GET_RECORD_VALUE_GAMES(resultSearch);
                for (auto column : columns)
                {
                    if (column == "publisher")
                    {
                        string publisher = string(record.publisher, sizeof(record.publisher));
                        // delete \0
                        while (publisher.back() == '\0')
                        {
                            publisher.pop_back();
                        }
                        cout << "publisher: " << publisher << endl;
                    }
                    if (column == "gameTitle")
                    {
                        string gameTitle = string(record.gameTitle, sizeof(record.gameTitle));
                        while (gameTitle.back() == '\0')
                        {
                            gameTitle.pop_back();
                        }
                        cout << "gameTitle: " << gameTitle << endl;
                    }
                    if (column == "price")
                    {
                        cout << "price: " << record.price << endl;
                    }
                }
            }
            else
            {
                cout << "Registro no se pudo encontrar" << endl;
            }
        }
    }

    if (action == "delete")
    {
        if (datasetFileName == "movies.csv" && dataStructure == "extendible_hashing")
        {
            int id = stoi(argv[6]);

            bool resultDelete = ExtendibleHashingMovies(indexFileName, dataFileName).remove(id);

            if (resultDelete)
            {
                cout << "Registro se eliminó correctamente" << endl;
            }
            else
            {
                cout << "Registro no se pudo eliminar" << endl;
            }
        }
        if (datasetFileName == "games.csv" && dataStructure == "extendible_hashing")
        {
            string gameTitlestr = argv[6];

            char gameTitle[TITLE_GAME_SIZE];
            strcpy(gameTitle, gameTitlestr.c_str());

            bool resultDelete = ExtendibleHashingGames(indexFileName, dataFileName).remove(gameTitle);

            if (resultDelete)
            {
                cout << "Registro se eliminó correctamente" << endl;
            }
            else
            {
                cout << "Registro no se pudo eliminar" << endl;
            }
        }
    }
    return 0;
}
