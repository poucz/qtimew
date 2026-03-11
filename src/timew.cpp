#include "timew.h"


#include <QProcess>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>


#define TIMEW_DATE_FORMAT_EXPORT "yyyyMMdd'T'hhmmss'Z'" //pro json - příkaz timew export
#define TIMEW_DATE_FORMAT "yyyy-MM-ddTHH:mm:ss" //klasika volani pro uživatele


TimeW::TimeW(QObject *parent)
    : QAbstractListModel{parent},
    durationSum(0)
{


    timewFilter.startFiltr =  QDateTime(QDate::currentDate().addMonths(-1), QTime(00,00,00));
    timewFilter.endFiltr = QDateTime(QDate::currentDate().addDays(0), QTime(23,59,59));




    watcher.addPath("/home/pou/.local/share/timewarrior/data/");
    connect(&watcher, &QFileSystemWatcher::directoryChanged, this, &TimeW::onDirectoryChanged);


    refresh();
    refresh_running();
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
        FILTR f;
        f.startFiltr=start;
        f.endFiltr=end;
        f.tagsFiltr=tags;
        QList<TimeEntry*> entryes=loadFiles(f);

        if(entryes.count()==1){
            runTimeWCmd(QStringList()<<"annotate"<<"@"+QString::number(entryes.at(0)->id())<<annotation);
        }
        destroyEntry(entryes);
    }
}




void TimeW::addTag(int id, const QString &tag){
    runTimeWCmd(QStringList()<<"tag"<<"@"+QString::number(id)<<tag);
}

void TimeW::delTag(int id, const QString &tag){
    runTimeWCmd(QStringList()<<"untag"<<"@"+QString::number(id)<<tag);
}



bool TimeW::isRunning() const{
    return m_running;
}

QStringList TimeW::runningTags() const{
    return m_runningTags;
}



QStringList TimeW::lastTags() const{
    return m_lastTags;
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




void TimeW::computeDuration(){
    durationSum=0;
    foreach (const auto itm, m_entries) {
        durationSum+=itm->duration();
    }
    emit durationChange();
}




void TimeW::setStartFiltr(const QDateTime &newFiltr){
    if(newFiltr==timewFilter.startFiltr){
        return;
    }
    timewFilter.startFiltr=newFiltr;
    emit filtrChanged();
    refresh();
}



void TimeW::setEndFiltr(const QDateTime &newFiltr){
    if(newFiltr==timewFilter.endFiltr){
        return;
    }
    timewFilter.endFiltr=newFiltr;
    emit filtrChanged();
    refresh();
}

void TimeW::setTagsFiltr(const QStringList &newFiltr){
    if(newFiltr==timewFilter.tagsFiltr){
        return;
    }
    timewFilter.tagsFiltr=newFiltr;
    emit filtrChanged();
    refresh();
}





void TimeW::refresh(){

    beginResetModel();
    destroyEntry(m_entries);
    m_entries=loadFiles(timewFilter);
    endResetModel();

    computeDuration();
    refresgTags();
    emit entriesChanged(); // pokud máš signal pro GUI
}




void TimeW::refresgTags(){
    //QByteArray output=runTimeWCmd(QStringList()<<"export"<<args);
    m_tags.clear();
    foreach (const auto itm, m_entries) {
        m_tags.append(itm->tags());
    }
    m_tags.removeDuplicates();
    emit tagsChanged();
}



void TimeW::refresh_running(){
    FILTR f;
    f.idFiltr.append(1);
    f.idFiltr.append(2);
    f.idFiltr.append(3);
    f.idFiltr.append(4);
    f.idFiltr.append(5);
    f.idFiltr.append(6);

    bool actRunniing=false;
    QStringList act_tags;
    m_lastTags.clear();

    QList<TimeEntry*> itms=loadFiles(f);
    if(!itms.isEmpty()){
        if(!itms.at(0)->end().isValid()){
            actRunniing=true;
            act_tags=itms.at(0)->tags();
        }
        foreach (TimeEntry * itm, itms) {
            m_lastTags<<itm->tags();
        }
    }
    destroyEntry(itms);
    m_lastTags.removeDuplicates();


    if(actRunniing!=isRunning()){
        m_running=actRunniing;
        emit runningChange();
    }


    if(!actRunniing){
        act_tags.clear();
    }

    if(act_tags!= m_runningTags){
        m_runningTags=act_tags;
        emit runningTagsChange();
    }

}


void TimeW::destroyEntry(QList<TimeEntry *> &list){
    foreach (TimeEntry * itm, list) {
        delete itm;
    }
    list.clear();
}

QList<TimeEntry *> TimeW::loadFiles(const FILTR &filtr) const{
    QList<TimeEntry *> ret;
    QStringList args;
    if(filtr.startFiltr.isValid()){
        args.append(time2UTF(filtr.startFiltr).toString(TIMEW_DATE_FORMAT_EXPORT));
        if(filtr.endFiltr.isValid()){//end bez start filtru asi nejde, protože range je určen "-"
            args.append("-");
            args.append(time2UTF(filtr.endFiltr).toString(TIMEW_DATE_FORMAT_EXPORT));
        }
    }

    if(!filtr.idFiltr.isEmpty()){
        foreach (int itm, filtr.idFiltr) {
            args.append("@"+QString::number(itm));
        }
    }

    args<<filtr.tagsFiltr;
    QByteArray output=runTimeWCmd(QStringList()<<"export"<<args);


    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(output, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "JSON parse error:" << parseError.errorString();
        return ret;
    }

    if (!doc.isArray()) {
        qWarning() << "Expected JSON array from timew export";
        return ret;
    }

    QJsonArray jsonArray = doc.array();
    for (const QJsonValue &val : jsonArray) {
        if (!val.isObject()) continue;
        QJsonObject obj = val.toObject();

        if(!obj.contains("id")){
            qWarning()<<"Entry have no ID!!!";
            continue;
        }

        TimeEntry *entry = new TimeEntry(obj["id"].toInt(),nullptr);
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


        ret.append(entry);
    }

    std::reverse(ret.begin(), ret.end());


    return ret;
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
    refresh_running();
}




