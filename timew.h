#ifndef TIMEW_H
#define TIMEW_H

#include <QObject>
#include <QQmlEngine>
#include <QAbstractListModel>
#include <QFileSystemWatcher>


#include "timeentry.h"

class TimeW : public QAbstractListModel
{
    Q_OBJECT

public:

    enum TimeEntryRoles {
        IdRole = Qt::UserRole + 1,
        StartRole,
        EndRole,
        TagsRole,
        AnnotationRole,
        DurationRole,
    };



    explicit TimeW(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    void addEntry(TimeEntry *entry) ;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    Q_INVOKABLE void removeItem(int id);
    Q_INVOKABLE void modifyEntry(TimeEntry* entry);
    Q_INVOKABLE void modifyEntry(int id, const QDateTime & start, const QDateTime & end, const QStringList &tags, const QString & annotation);
    Q_INVOKABLE void addEntry(const QDateTime & start, const QDateTime & end, const QStringList &tags, const QString & annotation);


    void refresh();
private:
    QList<TimeEntry*> m_entries;
    QFileSystemWatcher watcher;

    QByteArray runTimeWCmd(const QStringList & arg) const;
    void saveToDB(TimeEntry *entry);


private slots:
    void onDirectoryChanged(const QString &path);

signals:
    void entriesChanged();

};


#endif // TIMEW_H
