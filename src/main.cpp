#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext> // Nezapomeň na tento include


#include "timew.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);


    TimeW timew;


    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);


    //engine.rootContext()->setContextProperty("timew", &timew);
    engine.setInitialProperties({
        { "timew", QVariant::fromValue(&timew) },
    });

    engine.loadFromModule("qtimew", "Main");

    return app.exec();
}
