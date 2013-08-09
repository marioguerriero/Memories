import QtQuick 2.0
import U1db 1.0 as U1db

Item {
    U1db.Database {
        id: database
        path: "aU1DbDatabase"
    }

    U1db.Document {
        id: memoriesDatabase
        database: database
        docId: 'memoriesDatabase'
        //create: true
        //defaults: { "hello": "Hello World!" }
    }
}
