#include "timew.h"


#include <QProcess>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>


#define TIMEW_DATE_FORMAT "yyyyMMdd'T'hhmmss'Z'"


TimeW::TimeW(QObject *parent)
    : QAbstractListModel{parent}
{

    watcher.addPath("/home/pou/.local/share/timewarrior/data/");
    connect(&watcher, &QFileSystemWatcher::directoryChanged, this, &TimeW::onDirectoryChanged);


    refresh();

}


int TimeW::rowCount(const QModelIndex &parent) const{
    Q_UNUSED(parent);
    return m_entries.count();
}

QVariant TimeW::data(const QModelIndex &index, int role) const{

    if (!index.isValid() || index.row() < 0 || index.row() >= m_entries.count())
        return QVariant();

    TimeEntry *entry = m_entries[index.row()];
    switch(role) {
    case IdRole: return entry->id();
    case StartRole: return entry->start();
    case EndRole: return entry->end();
    case TagsRole: return entry->tags(); // <-- vrací celý QStringList
    case AnnotationRole: return entry->annotation();
    case DurationRole: return entry->duration();
    default: return QVariant();
    }
}

QHash<int, QByteArray> TimeW::roleNames() const{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[StartRole] = "start";
    roles[EndRole] = "end";
    roles[TagsRole] = "tags";
    roles[AnnotationRole] = "annotation";
    roles[DurationRole] = "duration";
    return roles;
}

void TimeW::addEntry(TimeEntry *entry){
    beginInsertRows(QModelIndex(), m_entries.count(), m_entries.count());
    m_entries.append(entry);
    endInsertRows();

    saveToDB(entry);
}


bool TimeW::setData(const QModelIndex &index, const QVariant &value, int role){

    if (!index.isValid() || index.row() >= m_entries.count())
        return false;

    int id=m_entries.at(index.row())->id();

    if (role == EndRole) {
        QDateTime newEnd=m_entries.at(index.row())->end();
        QTime t = QTime::fromString(value.toString(), "HH:mm:ss");
        if (t.isValid()==false) {
            return false;
        }
        newEnd.setTime(t);
        qInfo()<<"Měnim end "<<id<<"  - "<<m_entries.at(index.row())->end().toString()<<"  --> "<<newEnd.toString();
        runTimeWCmd(QStringList()<<"modify"<<"end"<<"@"+QString::number(id)<<newEnd.toString(TIMEW_DATE_FORMAT));
        emit dataChanged(index, index, {role});
        return true;
    }else if (role == StartRole) {
        QDateTime newStart=m_entries.at(index.row())->start();
        QTime t = QTime::fromString(value.toString(), "HH:mm:ss");
        if (t.isValid()==false) {
            return false;
        }
        newStart.setTime(t);
        qInfo()<<"Měnim end "<<id<<"  - "<<m_entries.at(index.row())->start().toString()<<"  --> "<<newStart.toString();
        runTimeWCmd(QStringList()<<"modify"<<"start"<<"@"+QString::number(id)<<newStart.toString(TIMEW_DATE_FORMAT));
        emit dataChanged(index, index, {role});
        return true;
    }
    return false;
}



Qt::ItemFlags TimeW::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEnabled
           | Qt::ItemIsSelectable
           | Qt::ItemIsEditable;
}


void TimeW::removeItem(int id){
    runTimeWCmd(QStringList()<<"delete"<<"@"+QString::number(id));
    refresh();
}





void TimeW::refresh(){
    // 1. Spustit "timew export"


    QByteArray output=runTimeWCmd(QStringList()<<"export");

    // 2. Parsovat JSON
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(output, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "JSON parse error:" << parseError.errorString();
        return;
    }

    if (!doc.isArray()) {
        qWarning() << "Expected JSON array from timew export";
        return;
    }

    QJsonArray jsonArray = doc.array();

    beginResetModel();

    m_entries.clear(); // předchozí data, m_entries je QList<TimeEntry*>

    for (const QJsonValue &val : jsonArray) {
        if (!val.isObject()) continue;
        QJsonObject obj = val.toObject();

        if(!obj.contains("id")){
            qWarning()<<"Entry have no ID!!!";
            continue;
        }

        TimeEntry *entry = new TimeEntry(obj["id"].toInt(),this);

        if (obj.contains("start")){
            entry->setStart(QDateTime::fromString(obj["start"].toString(), TIMEW_DATE_FORMAT));
        }
        if (obj.contains("end")){
            entry->setEnd(QDateTime::fromString(obj["end"].toString(), TIMEW_DATE_FORMAT));
        }

        if (obj.contains("annotation")){
            entry->setAnnotation(obj["annotation"].toString());
        }

        // tags
        if (obj.contains("tags") && obj["tags"].isArray()) {
            QStringList tags;
            for (const QJsonValue &t : obj["tags"].toArray())
                tags.append(t.toString());
            entry->setTags(tags);
        }

        //qDebug()<<"Pridan zaznam: "<<entry;
        connect(entry, &TimeEntry::entryChanged, this, [this, entry](){ saveToDB(entry); });
        m_entries.append(entry);
    }

    std::reverse(m_entries.begin(), m_entries.end());

    endResetModel();
    emit entriesChanged(); // pokud máš signal pro GUI
}




QByteArray TimeW::runTimeWCmd(const QStringList &arg) const{
    QProcess process;
    process.start("timew", arg);
    qInfo()<<"Cmd timew "<<arg.join(" ");

    if (!process.waitForFinished(3000)) { // čeká 3s
        qWarning() << "TimeW export failed or timed out";
        return QByteArray();
    }
    return process.readAllStandardOutput();
}



void TimeW::saveToDB(TimeEntry *entry){
    qInfo()<<"Zaznam se změnil: "<<entry;
}



void TimeW::onDirectoryChanged(const QString &path){
    qInfo() << "V adresáři" << path << "se něco změnilo!";
    refresh();
}




