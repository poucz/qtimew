#ifndef TIMEW_H
#define TIMEW_H

#include <QObject>
#include <QQmlEngine>
#include <QAbstractListModel>

#include "timeentry.h"

class TimeW : public QAbstractListModel
{
    Q_OBJECT

public:

    enum TimeEntryRoles {
        IdRole = Qt::UserRole + 1,
        StartRole,
        EndRole,
        TagsRole
    };



    explicit TimeW(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    void addEntry(TimeEntry *entry) ;


    void refresh();
private:
    QList<TimeEntry*> m_entries;

    QByteArray runTimeWCmd(const QStringList & arg) const;
    void saveToDB(TimeEntry *entry);

signals:
    void entriesChanged();
};


#endif // TIMEW_H
