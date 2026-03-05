#ifndef TIMEENTRY_H
#define TIMEENTRY_H

#include <QObject>
#include <QQmlEngine>

class TimeEntry : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    // QML properties
    Q_PROPERTY(int id               READ id                             NOTIFY idChanged)
    Q_PROPERTY(QDateTime start      READ start      WRITE setStart      NOTIFY startChanged)
    Q_PROPERTY(QDateTime end        READ end        WRITE setEnd        NOTIFY endChanged)
    Q_PROPERTY(QStringList tags     READ tags       WRITE setTags       NOTIFY tagsChanged)
    Q_PROPERTY(QString annotation   READ annotation WRITE setAnnotation NOTIFY annotationChanged)

public:
    explicit TimeEntry(int _id,QObject *parent = nullptr);

    int id()const {return m_id;}
    QDateTime start() const { return m_start; }
    QDateTime end() const { return m_end; }
    const QStringList &tags() const { return m_tags; }
    const QString &annotation()const { return m_annotation;};

    void setStart(const QDateTime &start);
    void setEnd(const QDateTime &end);
    void setTags(const QStringList &tags) ;
    void setAnnotation(const QString &annotation);

private:
    int m_id;
    QDateTime m_start;
    QDateTime m_end;
    QStringList m_tags;
    QString m_annotation;


signals:
    void idChanged();
    void startChanged();
    void endChanged();
    void tagsChanged();
    void annotationChanged();

    void entryChanged();
};



QDebug operator<<(QDebug debug, const TimeEntry &entry);
QDebug operator<<(QDebug debug, const TimeEntry *entry);

#endif // TIMEENTRY_H
