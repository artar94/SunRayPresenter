#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QPainter>
#include <QTcpSocket>
#include <QHostAddress>
#include <QImage>
#include <QDataStream>

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

private:
    Ui::MainWindow *ui;
    QTcpSocket * socket;
    QPainter * painter;
    QImage * image;
    QImage * current;
    QPainter * p;
    int x;
    int y;
    QDataStream * in;
    char * c;

private slots:
    void readdata();
    void paintEvent(QPaintEvent *);
};

#endif // MAINWINDOW_H
