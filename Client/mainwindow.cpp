#include "mainwindow.h"
#include "ui_mainwindow.h"


MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    //MainWindow::setAttribute(Qt::WA_PaintOutsidePaintEvent);
    painter = new QPainter();
    p = new QPainter();
    socket = new QTcpSocket(this);
    socket->connectToHost(QHostAddress("127.0.0.1"),6889);
    connect(socket,SIGNAL(readyRead()),SLOT(readdata()));
    image = new QImage();
    current = new QImage(1280,1024,QImage::Format_RGB32);
    //connect(this, SIGNAL())
    in = new QDataStream(socket);
    c = new char[65536];
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::readdata() {

    //QDataStream in(socket);
    if (socket->bytesAvailable()>=65536) {
        socket->read(c,65536);
        image->loadFromData((uchar*)c,65536,0);
        char index = (char)c[49206];
        x = (index % 10)*128;
        y = (index / 10)*128;
        p->begin(current);
        p->drawImage(x,y,*image);
        p->end();

        //delete p;
        this->update();
    }
}

void MainWindow::paintEvent(QPaintEvent * e)
{
    //QPainter painter;
    painter->begin(this);
    painter->drawImage(0,0,*current);
    painter->end();
    //delete painter;
}
