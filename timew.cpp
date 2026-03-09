#include "timew.h"


#include <QProcess>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>


#define TIMEW_DATE_FORMAT_EXPORT "yyyyMMdd'T'hhmmss'Z'" //pro json - příkaz timew export
#define TIMEW_DATE_FORMAT "yyyy-MM-ddTHH:mm:ss" //klasika volani pro uživatele


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

    if (role == TagsRole) {
        qInfo()<<"novy tagy:"<<value.toStringList().join(", ") ;
    }

    qInfo()<<"Vole faka to!!!!!!!!!! id:"<<id<<" role:"<<role<<" hodnota:"<<value.toString();
    return false;


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
    //efresh();//zavola se automaticky, pač se změní soubory
}



void TimeW::modifyEntry(TimeEntry *entry){
    qInfo()<<"Vole faka to!!!!!!!!!! id:"<<entry;
}



void TimeW::modifyEntry(int id, const QDateTime &start, const QDateTime &end,const QStringList &tags, const QString &annotation){
    removeItem(id);
    addEntry(start,end,tags,annotation);
}



void TimeW::addEntry(const QDateTime &start, const QDateTime &end, const QStringList &tags, const QString &annotation){
    QStringList args;
    args.append("track");
    args.append(start.toString(TIMEW_DATE_FORMAT));
    if(end.isValid()){
        args.append("-");
        args.append(end.toString(TIMEW_DATE_FORMAT));
    }

    args<<tags;
    runTimeWCmd(args);

    if(annotation!=""){
        FILTR old=timewFilter;
        timewFilter.startFiltr=start;
        timewFilter.endFiltr=end;
        timewFilter.tagsFiltr=tags;
        refresh();
        if(m_entries.count()==1){
            runTimeWCmd(QStringList()<<"annotate"<<"@"+QString::number(m_entries.at(0)->id())<<annotation);
        }
        timewFilter=old;
        refresh();
    }
}




void TimeW::addTag(int id, const QString &tag){
    runTimeWCmd(QStringList()<<"tag"<<"@"+QString::number(id)<<tag);
}

void TimeW::delTag(int id, const QString &tag){
    runTimeWCmd(QStringList()<<"untag"<<"@"+QString::number(id)<<tag);
}



bool TimeW::isRunning() const{
    if(!m_entries.isEmpty()){
        if(! m_entries.at(0)->end().isValid()){
            return true;
        }
    }
    return false;
}


void TimeW::setRunning(bool setRunn){
    if(setRunn){
        runTimeWCmd(QStringList()<<"start");
    }else{
        runTimeWCmd(QStringList()<<"stop");
    }
    refresh();
    emit runningChange();
}




void TimeW::setStartFiltr(const QDateTime &newFiltr){
    if(newFiltr==timewFilter.startFiltr){
        return;
    }
    timewFilter.startFiltr=newFiltr;
    emit filtrChanged();
}



void TimeW::setEndFiltr(const QDateTime &newFiltr){
    if(newFiltr==timewFilter.endFiltr){
        return;
    }
    timewFilter.endFiltr=newFiltr;
    emit filtrChanged();
}

void TimeW::setTagsFiltr(const QStringList &newFiltr){
    if(newFiltr==timewFilter.tagsFiltr){
        return;
    }
    timewFilter.tagsFiltr=newFiltr;
    emit filtrChanged();
}







void TimeW::refresh(){

    // 1. Spustit "timew export"
    QStringList args;
    if(timewFilter.startFiltr.isValid()){
        args.append(time2UTF(timewFilter.startFiltr).toString(TIMEW_DATE_FORMAT_EXPORT));
        if(timewFilter.endFiltr.isValid()){//end bez start filtru asi nejde, protože range je určen "-"
            args.append("-");
            args.append(time2UTF(timewFilter.endFiltr).toString(TIMEW_DATE_FORMAT_EXPORT));
        }
    }

    args<<timewFilter.tagsFiltr;
    QByteArray output=runTimeWCmd(QStringList()<<"export"<<args);

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
            entry->setStart(time2LOCAL(QDateTime::fromString(obj["start"].toString(), TIMEW_DATE_FORMAT_EXPORT)));
        }
        if (obj.contains("end")){
            entry->setEnd(time2LOCAL(QDateTime::fromString(obj["end"].toString(), TIMEW_DATE_FORMAT_EXPORT)));
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



void TimeW::refresgTags(){

}


QDateTime TimeW::time2UTF(const QDateTime &t) const{
    QDateTime dt=t;
    dt.setTimeZone(QTimeZone::LocalTime);
    return dt.toUTC();
}

QDateTime TimeW::time2LOCAL(const QDateTime &t) const{
    QDateTime dt=t;
    dt.setTimeZone(QTimeZone::UTC);
    return dt.toLocalTime();
}




QByteArray TimeW::runTimeWCmd(const QStringList &arg) const{
    QProcess process;
    process.start("timew", arg);
    qInfo()<<"Cmd timew "<<arg.join(" ");

    if (!process.waitForFinished(3000)) { // čeká 3s
        qWarning() << "TimeW export failed or timed out";
        return QByteArray();
    }

    if(process.exitCode()!=0){
        qWarning() << "TimeW CMD error: "<<process.readAllStandardError();
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




