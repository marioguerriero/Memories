/**
 * This file is part of Memories.
 *
 * Copyright 2013 (C) Giulio Collura <random.cpp@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

#include "Utils.h"

#include <QtCore>
#include <QTextDocument>
#include <QStandardPaths>
#include <QtPrintSupport/QPrinter>

Utils::Utils(QObject *parent) :
    QObject(parent) {

}

Utils::~Utils() {

}

bool Utils::createDir(const QString &dirName) {
    QDir dir(dirName);
    if (!dir.exists())
        dir.mkpath(".");

    return dir.exists();
}

QString Utils::homePath() const {
    return QDir::homePath();
}

QString Utils::imagePath() const {
    QString home = Utils::homePath();
    return home + "/" + QStandardPaths::displayName(QStandardPaths::PicturesLocation);
}

bool Utils::fileExists(const QString& path) const {
    QFile file(path);
    return file.exists();
}

bool Utils::write(const QString& dirName, const QString& fileName, const QString& contents) {
    if (!createDir(dirName))
        return false;
    QString path = QDir(dirName).absoluteFilePath(fileName);
    path = QDir::cleanPath(path);

    QFile file(path);

    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream stream(&file);
        stream << contents << endl;
        file.close();
        return true;
    } else {
        return false;
    }
}

QString Utils::read(const QString& dirName, const QString& fileName) {
    QString path = QDir(dirName).absoluteFilePath(fileName);
    path = QDir::cleanPath(path);
    QFile file(path);

    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QString contents = QString(file.readAll());
        return contents;
    } else {
        // Return an empty string if the file doesn't exists or it's impossible to read
        return QString();
    }
}

bool Utils::exportAsPdf(const QString &fileName, const QJsonObject &contents) {
    QTextDocument doc;
    QString html;
    QTextStream stream(&html);

    stream << QString("<h1>%1</h1>").arg(contents["title"].toString());
    stream << QString("<h2>%1</h2>").arg(contents["date"].toString());
    stream << QString("<h3>%1</h3>").arg(contents["location"].toString());

    stream << QString("<hr>");

    stream << QString("%1").arg(contents["description"].toString());

    stream << QString("<br><br><br><br>");

    QJsonArray photos = contents["photos"].toArray();
    for (int i = 0; i < photos.count(); i++)
        stream << QString("<img src='%1' height=125 width=125>").arg(photos[i].toString());

    doc.setHtml(html);

    QPrinter printer;
    printer.setOutputFileName(fileName);
    printer.setOutputFormat(QPrinter::PdfFormat);
    doc.print(&printer);
    printer.newPage();

    return true;
}
