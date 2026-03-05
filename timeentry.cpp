#include "timeentry.h"

TimeEntry::TimeEntry(int _id, QObject *parent)
    : QObject{parent},
    m_id(_id),
    m_duration(0)
{}

void TimeEntry::setStart(const QDateTime &start){
    if (m_start != start) {
        m_start = start;
        emit startChanged();
        emit entryChanged();
        computeDuration();
    }
}

void TimeEntry::setEnd(const QDateTime &end){
    if (m_end != end) {
        m_end = end;
        emit endChanged();
        emit entryChanged();
        computeDuration();
    }
}

void TimeEntry::setTags(const QStringList &tags){
    if (m_tags != tags) {
        m_tags = tags;
        emit tagsChanged();
        emit entryChanged();
    }
}

void TimeEntry::setAnnotation(const QString &annotation){
    if (m_annotation != annotation) {
        m_annotation = annotation;
        emit annotationChanged();
        emit entryChanged();
    }
}



void TimeEntry::computeDuration() {
    int new_duration=0;
    if (m_end.isValid() && m_start.isValid()) {
        // Délka v sekundách
        new_duration = m_start.secsTo(m_end);
    }

    if(new_duration != m_duration){
        m_duration=new_duration;
        emit durationChanged();
        emit entryChanged();
    }
}


QDebug operator<<(QDebug debug, const TimeEntry &entry){
    QDebugStateSaver saver(debug); // Zajistí správné formátování (mezery atd.)
    debug.nospace() << "ID: " << entry.id() << " " << entry.start()<<" - "<<entry.end() << " - "<<entry.tags().join(",")<<" ("<<entry.annotation()<<")";
    return debug;
}

QDebug operator<<(QDebug debug, const TimeEntry *entry){
    if (!entry) {
        return debug << "TimeEntry(nullptr)";
    }
    return debug << *entry; // Volá první definovaný operátor
}
