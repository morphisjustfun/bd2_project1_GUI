#pragma once

#define GLOBAL_DEPTH 16
#define BUCKET_SIZE 400
#define HAS_RECORD_VALUE(x) (x.index() == 0)
#define GET_RECORD_VALUE_MOVIES(x) (get<RecordMovies>(x))
#define GET_RECORD_VALUE_GAMES(x) (get<RecordGames>(x))
#define TITLE_GAME_SIZE 150

#include <bits/stdc++.h>

using namespace std;

using ul = unsigned long;

struct RecordGames
{
    char publisher[90];
    char gameTitle[TITLE_GAME_SIZE];
    float price;
    bool deleted;
};

struct DataRecordGames
{
    int size;
    RecordGames records[BUCKET_SIZE];
    int nextPointer; // physical address of the next bucket
};

struct IndexRecordGames
{
    int depth;
    int value;   // unique
    int pointer; // physical address of the bucket
};

class ExtendibleHashingGames
{
    string indexFileName;
    string dataFileName;

private:
    // hash of the index
    static int hash(char gameTitle[TITLE_GAME_SIZE])
    {
        int hashValue = 0;
        for (int i = 0; i < TITLE_GAME_SIZE; i++)
        {
            if (gameTitle[i] == '\0')
                break;
            hashValue += gameTitle[i];
        }
        return hashValue % (1 << GLOBAL_DEPTH);
    }

    // return the size of the file in bytes using filesystem API
    ul getIndexFileSize()
    {
        return filesystem::file_size(indexFileName);
    }

public:
    explicit ExtendibleHashingGames(const string &indexFileName, const string &dataFileName)
    {
        this->indexFileName = indexFileName;
        this->dataFileName = dataFileName;
        fstream indexFile(indexFileName, ios::in | ios::out | ios::binary);
        if (getIndexFileSize() == 0)
        {
            int totalIndexRecords = (1 << GLOBAL_DEPTH);
            indexFile.seekp(0, ios::beg);
            for (int i = 0; i < totalIndexRecords; i++)
            {
                if (i == 0)
                {
                    IndexRecordGames indexRecord1{1, 0, -1};
                    indexFile.write((char *)&indexRecord1, sizeof(IndexRecordGames));
                }
                else if (i == 1)
                {
                    IndexRecordGames indexRecord2{1, 1, -1};
                    indexFile.write((char *)&indexRecord2, sizeof(IndexRecordGames));
                }
                else
                {
                    IndexRecordGames genericIndexRecord{0, 0, -1};
                    indexFile.write((char *)&genericIndexRecord, sizeof(IndexRecordGames));
                }
            }
        }
    }

    // returns variant<RecordGames, nullptr_t>
    // if record is found, returns RecordGames
    // otherwise returns nullptr
    variant<RecordGames, nullptr_t> search(char gameTitle[TITLE_GAME_SIZE])
    {
        fstream dataFile(dataFileName, ios::in | ios::binary);
        fstream indexFile(indexFileName, ios::in | ios::binary);

        int hashValue = hash(gameTitle);

        int initialDepth = GLOBAL_DEPTH;
        IndexRecordGames selectedIndexRecord{};

        while (initialDepth != 0)
        {
            int compare = hashValue & ((1 << initialDepth) - 1);
            IndexRecordGames tempIndexRecord{};
            int tempIndexRecordPosition = compare * sizeof(IndexRecordGames);
            indexFile.seekg(tempIndexRecordPosition, ios::beg);
            indexFile.read((char *)&tempIndexRecord, sizeof(IndexRecordGames));
            if (tempIndexRecord.depth != 0)
            {
                selectedIndexRecord = tempIndexRecord;
                break;
            }
            initialDepth--;
        }

        if (selectedIndexRecord.pointer == -1)
        {
            return nullptr;
        }

        DataRecordGames dataRecord{};
        dataFile.seekg(selectedIndexRecord.pointer, ios::beg);
        dataFile.read((char *)&dataRecord, sizeof(DataRecordGames));

        while (true)
        {
            for (int i = 0; i < dataRecord.size; i++)
            {
                if (strcmp(dataRecord.records[i].gameTitle, gameTitle) == 0)
                {
                    RecordGames recordSelected = dataRecord.records[i];
                    if (recordSelected.deleted)
                    {
                        return nullptr;
                    }
                    return recordSelected;
                }
            }
            if (dataRecord.nextPointer == -1)
            {
                break;
            }
            dataFile.seekg(dataRecord.nextPointer, ios::beg);
            dataFile.read((char *)&dataRecord, sizeof(DataRecordGames));
        }

        return nullptr;
    }

    // return add if value was added
    // otherwise returns false
    bool add(RecordGames record)
    {
        record.deleted = false;
        fstream indexFile(indexFileName, ios::in | ios::out | ios::binary);
        fstream dataFile(dataFileName, ios::in | ios::out | ios::binary);

        int hashValue = hash(record.gameTitle);

        int initialDepth = GLOBAL_DEPTH;
        IndexRecordGames selectedIndexRecord{};
        int selectedIndexRecordPosition;

        while (initialDepth != 0)
        {
            int compare = hashValue & ((1 << initialDepth) - 1);
            IndexRecordGames tempIndexRecord{};
            int tempIndexRecordPosition = compare * sizeof(IndexRecordGames);
            indexFile.seekg(tempIndexRecordPosition, ios::beg);
            indexFile.read((char *)&tempIndexRecord, sizeof(IndexRecordGames));
            if (tempIndexRecord.depth != 0)
            {
                selectedIndexRecord = tempIndexRecord;
                selectedIndexRecordPosition = tempIndexRecordPosition;
                break;
            }
            initialDepth--;
        }

        if (selectedIndexRecord.pointer == -1)
        {
            dataFile.seekp(0, ios::end);
            int pointer = dataFile.tellp();
            selectedIndexRecord.pointer = pointer;
            DataRecordGames dataRecord{};

            dataRecord.size = 1;
            dataRecord.records[0] = record;
            dataRecord.nextPointer = -1;

            dataFile.write((char *)&dataRecord, sizeof(DataRecordGames));
            indexFile.seekp(selectedIndexRecordPosition);
            indexFile.write((char *)&selectedIndexRecord, sizeof(IndexRecordGames));
        }
        else
        {
            DataRecordGames dataRecord{};
            dataFile.seekg(selectedIndexRecord.pointer, ios::beg);
            dataFile.read((char *)&dataRecord, sizeof(DataRecordGames));

            if (dataRecord.size < BUCKET_SIZE)
            {
                dataRecord.records[dataRecord.size] = record;
                dataRecord.size++;
                dataFile.seekp(selectedIndexRecord.pointer, ios::beg);
                dataFile.write((char *)&dataRecord, sizeof(DataRecordGames));
            }
            else
            {
                if (selectedIndexRecord.depth == GLOBAL_DEPTH)
                {
                    // iterate over the nextPointer until it is -1
                    // use the nextPointer to find the next bucket
                    DataRecordGames newDataRecord{};

                    // pass all values to the newDataRecord
                    for (int i = 0; i < dataRecord.size; i++)
                    {
                        newDataRecord.records[i] = dataRecord.records[i];
                    }

                    newDataRecord.size = dataRecord.size;
                    newDataRecord.nextPointer = -1;

                    // write at the end of dataFile new dataRecord
                    dataFile.seekp(0, ios::end);
                    int newDatRecordPosition = dataFile.tellp();
                    dataFile.write((char *)&newDataRecord, sizeof(DataRecordGames));

                    // update the nextPointer of the last dataRecord
                    // dataRecord.nextPointer = newDatRecordPosition;
                    dataRecord.size = 1;
                    dataRecord.records[0] = record;
                    dataFile.seekp(selectedIndexRecord.pointer, ios::beg);
                    dataFile.write((char *)&dataRecord, sizeof(DataRecordGames));

                    // update the nextPointer of the last dataRecord in the chain
                    int currentDataRecordPosition = selectedIndexRecord.pointer;
                    DataRecordGames lastDataRecord = dataRecord;
                    while (lastDataRecord.nextPointer != -1)
                    {
                        currentDataRecordPosition = lastDataRecord.nextPointer;
                        dataFile.seekg(lastDataRecord.nextPointer, ios::beg);
                        dataFile.read((char *)&lastDataRecord, sizeof(DataRecordGames));
                    }

                    lastDataRecord.nextPointer = newDatRecordPosition;
                    dataFile.seekp(currentDataRecordPosition, ios::beg);
                    dataFile.write((char *)&lastDataRecord, sizeof(DataRecordGames));
                }
                else
                {
                    DataRecordGames newDataRecord{};
                    newDataRecord.size = 0;

                    RecordGames tempRecords[BUCKET_SIZE];
                    int sizeTempRecords = 0;

                    int sizeDataRecord = dataRecord.size;
                    RecordGames valueToReinsert{};

                    for (int i = 0; i <= sizeDataRecord; i++)
                    {
                        RecordGames currentRecord{};

                        if (i < dataRecord.size)
                        {
                            currentRecord = dataRecord.records[i];
                        }
                        else
                        {
                            currentRecord = record;
                        }

                        // store in compare the result of above operation
                        int compare = hash(currentRecord.gameTitle) & ((1 << (selectedIndexRecord.depth + 1)) - 1);

                        if (compare == selectedIndexRecord.value)
                        {
                            if (sizeTempRecords == BUCKET_SIZE)
                            {
                                sizeTempRecords++;
                                break;
                            }
                            tempRecords[sizeTempRecords] = currentRecord;
                            sizeTempRecords++;
                        }
                        else
                        {
                            if (newDataRecord.size == BUCKET_SIZE)
                            {
                                newDataRecord.size++;
                                break;
                            }
                            newDataRecord.records[newDataRecord.size] = currentRecord;
                            newDataRecord.size++;
                        }
                    }

                    for (int i = 0; i < BUCKET_SIZE; i++)
                    {
                        dataRecord.records[i] = tempRecords[i];
                    }
                    dataRecord.size = sizeTempRecords;

                    bool needReinsert = false;
                    if (dataRecord.size > BUCKET_SIZE)
                    {
                        needReinsert = true;
                        valueToReinsert = record;
                        dataRecord.size--;
                    }

                    if (newDataRecord.size > BUCKET_SIZE)
                    {
                        needReinsert = true;
                        valueToReinsert = record;
                        newDataRecord.size--;
                    }

                    newDataRecord.nextPointer = -1;
                    dataFile.seekp(selectedIndexRecord.pointer, ios::beg);
                    dataFile.write((char *)&dataRecord, sizeof(DataRecordGames));

                    // write at the end of dataFile new dataRecord
                    dataFile.seekp(0, ios::end);
                    int newDatRecordPosition = dataFile.tellp();
                    dataFile.write((char *)&newDataRecord, sizeof(DataRecordGames));

                    // first replace the current and add 1 to the left of the value and increase depth by 1
                    selectedIndexRecord.depth++;
                    indexFile.seekp(selectedIndexRecordPosition);
                    indexFile.write((char *)&selectedIndexRecord, sizeof(IndexRecordGames));

                    // add a 1 to the left
                    selectedIndexRecord.value =
                        selectedIndexRecord.value | (1 << (selectedIndexRecord.depth - 1));
                    selectedIndexRecord.pointer = newDatRecordPosition;
                    indexFile.seekp(selectedIndexRecord.value * sizeof(IndexRecordGames), ios::beg);
                    indexFile.write((char *)&selectedIndexRecord, sizeof(IndexRecordGames));

                    if (needReinsert)
                    {
                        dataFile.flush();
                        indexFile.flush();
                        auto result = add(valueToReinsert);
                        return result;
                    }
                }
            }
        }

        return true;
    }

    // returns true if value was deleted
    // otherwise returns false
    // logical delete. It finds the record and sets the deleted flag to true
    bool remove(char gameTitle[TITLE_GAME_SIZE])
    {
        fstream dataFile(dataFileName, ios::in | ios::out | ios::binary);
        fstream indexFile(indexFileName, ios::in | ios::binary);

        int hashValue = hash(gameTitle);

        int initialDepth = GLOBAL_DEPTH;
        IndexRecordGames selectedIndexRecord{};

        while (initialDepth != 0)
        {
            int compare = hashValue & ((1 << initialDepth) - 1);
            IndexRecordGames tempIndexRecord{};
            int tempIndexRecordPosition = compare * sizeof(IndexRecordGames);
            indexFile.seekg(tempIndexRecordPosition, ios::beg);
            indexFile.read((char *)&tempIndexRecord, sizeof(IndexRecordGames));
            if (tempIndexRecord.depth != 0)
            {
                selectedIndexRecord = tempIndexRecord;
                break;
            }
            initialDepth--;
        }

        if (selectedIndexRecord.pointer == -1)
        {
            return false;
        }

        DataRecordGames dataRecord{};
        int lastPointer = selectedIndexRecord.pointer;
        dataFile.seekg(lastPointer, ios::beg);
        dataFile.read((char *)&dataRecord, sizeof(DataRecordGames));

        while (true)
        {
            for (int i = 0; i < dataRecord.size; i++)
            {
                if (strcmp(dataRecord.records[i].gameTitle, gameTitle) == 0)
                {
                    RecordGames recordSelected = dataRecord.records[i];
                    if (recordSelected.deleted)
                    {
                        return true;
                    }
                    recordSelected.deleted = true;
                    dataRecord.records[i] = recordSelected;

                    dataFile.seekp(lastPointer, ios::beg);
                    dataFile.write((char *)&dataRecord, sizeof(DataRecordGames));
                    return true;
                }
            }
            if (dataRecord.nextPointer == -1)
            {
                break;
            }
            lastPointer = dataRecord.nextPointer;
            dataFile.seekg(lastPointer, ios::beg);
            dataFile.read((char *)&dataRecord, sizeof(DataRecordGames));
        }

        return false;
    }

    void seed(int maxValues, const string &datasetFileName)
    {
        ifstream datasetFile(datasetFileName);
        string line;
        getline(datasetFile, line); // skip first line
        int counter = 0;
        char delimiter = '|';
        vector<RecordGames> records;
        while (getline(datasetFile, line))
        {
            if (counter == maxValues)
            {
                break;
            }
            RecordGames record{};
            stringstream ss(line);
            string token;

            getline(ss, token, delimiter);
            strcpy(record.publisher, token.c_str());

            getline(ss, token, delimiter);
            strcpy(record.gameTitle, token.c_str());

            getline(ss, token, delimiter);
            record.price = stof(token);

            record.deleted = false;
            records.push_back(record);
            counter++;
        }
        shuffle(records.begin(), records.end(), std::mt19937(std::random_device()()));

        for (RecordGames const &record : records)
        {
            add(record);
        }
        return;
    }
};
