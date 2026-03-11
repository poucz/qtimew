#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSystemTrayIcon>
#include <QMenu>
#include <QAction>
#include <QWindow>
#include <QPainter>
#include <QFont>
#include <QTimer>
#include "timew.h"

// Vytvoří ikonu z UTF znaku
static QIcon iconFromText(const QString &text, const QColor &color)
{
    QPixmap pixmap(64, 64);
    pixmap.fill(Qt::transparent);
    QPainter painter(&pixmap);
    QFont font = painter.font();
    font.setPixelSize(52);
    painter.setFont(font);
    painter.setPen(color);
    painter.drawText(pixmap.rect(), Qt::AlignCenter, text);
    return QIcon(pixmap);
}


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setQuitOnLastWindowClosed(false);

    TimeW timew;
    QQmlApplicationEngine engine;

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.setInitialProperties({
                                 { "timew", QVariant::fromValue(&timew) },
                                 });
    engine.loadFromModule("qtimew", "Main");

    QWindow *window = qobject_cast<QWindow *>(engine.rootObjects().first());

    QSystemTrayIcon trayIcon;
    trayIcon.setToolTip("QTimeWarrior");

    // Funkce pro aktualizaci ikony a tooltipu
    auto updateTray = [&]() {
        if (timew.isRunning()) {
            if(timew.runningTags().count()==0){
                trayIcon.setIcon(iconFromText("▶", QColor("yellow"))); // zelená šipka
            }else{
                trayIcon.setIcon(iconFromText("▶", QColor("#4CAF50"))); // zelená šipka
            }
            trayIcon.setToolTip("QTimeWarrior – " + timew.runningTags().join("\n"));
        } else {
            trayIcon.setIcon(iconFromText("■", QColor("#F44336"))); // červený čtvereček
            trayIcon.setToolTip("QTimeWarrior – stopped");
        }
    };

    // Napojení na signal
    QObject::connect(&timew, &TimeW::runningChange, &app, updateTray);
    QObject::connect(&timew, &TimeW::runningTagsChange, &app, updateTray);

    // Skrýt okno při ztrátě fokusu
    QObject::connect(window, &QWindow::activeChanged, [&]() {
        if (!window->isActive()) {
            static QPoint lastPos = window->position();
            QPoint currentPos = window->position();
            if (currentPos == lastPos) {
                window->hide();
            }
            lastPos = currentPos;
        }
    });

    // Inicializace při startu
    updateTray();

    QObject::connect(&trayIcon, &QSystemTrayIcon::activated,
                     [&](QSystemTrayIcon::ActivationReason reason) {
                         if (reason == QSystemTrayIcon::Trigger) {
                             if (window->isVisible()) {
                                 window->hide();
                             } else {
                                 window->show();
                                 window->raise();
                                 window->requestActivate();
                             }
                         }
                     });

    QMenu menu;

    QAction *trackAction = menu.addAction("");
    auto updateTrackAction = [&]() {
        trackAction->setText(timew.isRunning() ? "Stop" : "Start");
    };
    updateTrackAction(); // inicializace
    QObject::connect(&timew, &TimeW::runningChange, &app, updateTrackAction);
    QObject::connect(trackAction, &QAction::triggered, [&]() {
        if (timew.isRunning()) timew.setRunning(false);
        else timew.setRunning(true);
    });


    QAction *toggleAction = menu.addAction("Zobrazit / Skrýt");
    QAction *quitAction   = menu.addAction("Ukončit");

    QObject::connect(toggleAction, &QAction::triggered, [&]() {
        if (window->isVisible()) window->hide();
        else { window->show(); window->raise(); window->requestActivate(); }
    });
    QObject::connect(quitAction, &QAction::triggered, &app, &QCoreApplication::quit);

    trayIcon.setContextMenu(&menu);
    trayIcon.show();

    return app.exec();
}
