#include "timeentry.h"

TimeEntry::TimeEntry(int _id, QObject *parent)
    : QObject{parent},
    m_id(_id)
{}

void TimeEntry::setStart(const QDateTime &start){
    if (m_start != start) {
        m_start = start;
        emit startChanged();
        emit entryChanged();
    }
}

void TimeEntry::setEnd(const QDateTime &end){
    if (m_end != end) {
        m_end = end;
        emit endChanged();
        emit entryChanged();
    }
}

void TimeEntry::setTags(const QStringList &tags){
    if (m_tags != tags) {
        m_tags = tags;
        emit tagsChanged();
        emit entryChanged();
    }
}



QDebug operator<<(QDebug debug, const TimeEntry &entry){
    QDebugStateSaver saver(debug); // Zajistí správné formátování (mezery atd.)
    debug.nospace() << "ID: " << entry.id() << " " << entry.start()<<" - "<<entry.end() << " - "<<entry.tags().join(",");
    return debug;
}

QDebug operator<<(QDebug debug, const TimeEntry *entry){
    if (!entry) {
        return debug << "TimeEntry(nullptr)";
    }
    return debug << *entry; // Volá první definovaný operátor
}
