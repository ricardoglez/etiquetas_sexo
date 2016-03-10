import gab.opencv.*;
import java.awt.Rectangle;
import processing.video.*;

PrintWriter output;

int numAudios = 24;
PImage imgFondo;
PFont font;

Capture captura; // Captura de Video
OpenCV caraCV; // Vision computarizada detectora de caraCV
OpenCV ojosCV; // Detectora de ojos
OpenCV narizCV;
OpenCV bocaCV;
Rectangle[] caras; // Arreglo de la infomracion de la caraCV
Rectangle[] ojos; // Arreglo de la infomracion de la ojosCV
Rectangle[] nariz;
Rectangle[] boca;
int[] fondoPixeles; // Pixeles del fondo Fijo
boolean hayAlguien; // Si  o No
PGraphics fondoCaptura; // Lienzo donde se almacena la captura del fondo sin personas
//50 Muestras de cada uno
int numMuestras = 5;

int[][] caraDatos = new int[4][numMuestras] ; //x, y ,w, h //
int[][] ojosDatos = new int[8][numMuestras]; //x0, y0 ,w0, h0, //x1, y1 ,w1, h1
int[][] bocaDatos = new int[4][numMuestras];//x, y ,w, h
int[][] narizDatos = new int[4][numMuestras];//x, y ,w, h

/*//////////////////////////////////////////7
 INICIALIZACION DE VARIABLES Y PROCESOS BASE
 */////////////////////////////////////////////
void setup() {
  size(1280, 720);
  background(255);
  output= createWriter("dataCara.txt");
  //println(Capture.list());
  //Inicializacion de captura, procesos de CV y creación de lienzo
  fondoPixeles = new int[width * height];
  captura = new Capture(this, 320, 240, "/dev/video0", 30);
  captura.start();
  hayAlguien = false;
  font = loadFont("Courier10PitchBT-Roman-48.vlw");
  imgFondo = loadImage("fondo.jpg");
  caraCV = new OpenCV(this, captura);
  ojosCV = new OpenCV(this, captura);
  narizCV = new OpenCV(this, captura);
  bocaCV  = new OpenCV(this, captura);
  caraCV.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  ojosCV.loadCascade(OpenCV.CASCADE_EYE); 
  narizCV.loadCascade(OpenCV.CASCADE_NOSE); 
  bocaCV.loadCascade(OpenCV.CASCADE_MOUTH); 
  fondoCaptura = createGraphics(width, height);
}
/*/////////////////////7
 LOOP INICIAL
 Todo lo que sucede aqui se trabaja en la capa base de processing
 *////////////////////////
void draw() {
  pushMatrix();
  translate(84, -55);
  scale(3.1);
  background(255);
  //fill(50,50,50,100);
  stroke(0);
  noFill();
  //image(fondoC, -127, -26);
  preprocessings();
  image(captura, 0, 0);
  startDet();
  writeData();
  popMatrix();
}
/*/////////////////////////////////////////////////////////////////
 Aqui se cargan las imagenes y se preprocesan para la vision computarizada
 */////////////////////////////////////////////////////////////////////
void preprocessings() {
  // Leer y cargar la captura de la camara al opencv
  captura.read();
  caraCV.loadImage(captura);
  ojosCV.loadImage(captura);
  narizCV.loadImage(captura);
  bocaCV.loadImage(captura);
}
/*/////////////////////////////////////77
 Detecta si hay alguna cara en la escena
 *///////////////////////////////////
boolean startDet() {
  int xCara_, yCara_, wCara_, hCara_, 
    xOjo0_, yOjo0_, wOjo0_, hOjo0_, 
    xOjo1_, yOjo1_, wOjo1_, hOjo1_, 
    xNariz_, yNariz_, wNariz_, hNariz_, 
    xBoca_, yBoca_, wBoca_, hBoca_;
  caras = caraCV.detect();
  ojos = ojosCV.detect();
  nariz = narizCV.detect();
  boca = bocaCV.detect();
  if (caras.length !=0) { //Si detecta una caraCV ..
    hayAlguien = true;
    for (int i = 0; i < caras.length; i++) { // Dibuja caraCV si son minimo de 50px ...
      if (caras[i].width >= 50) {
        for (int item = 0; item <= numMuestras-1; item++) {
          xCara_ = caras[i].x; // ubicacion de cara x
          yCara_ = caras[i].y; // ubicacion de cara y
          wCara_ = caras[i].width; // ancho de cara
          hCara_ = caras[i].height;// alto de cara 
          caraDatos[0][item] = xCara_;
          caraDatos[1][item] = yCara_;
          caraDatos[2][item] = wCara_;
          caraDatos[3][item] = hCara_;
          strokeWeight(3);
          stroke(#FF0000);
          noFill();
          rect(caraDatos[0][item], caraDatos[1][item], caraDatos[2][item], caraDatos[3][item]);

          // En cada cara debe haber 2 ojos
          if ((ojos.length == 2) 
            && ((ojos[1].x > caraDatos[0][item])&&(ojos[1].x < caraDatos[0][item]+caraDatos[2][item]))
            && ((ojos[1].y > caraDatos[1][item])&&(ojos[1].y < caraDatos[1][item]+caraDatos[3][item]))
            ) { //Si detecta 2 ojos dentro del area de la cara dibuja los ojos

            xOjo0_ = ojos[0].x; // ubicacion de ojo x
            yOjo0_ = ojos[0].y; // ubicacion de ojo y
            wOjo0_ = ojos[0].width; // ancho de ojo
            hOjo0_ = ojos[0].height;// alto de ojo 

            xOjo1_ = ojos[1].x; // ubicacion de ojo x
            yOjo1_ = ojos[1].y; // ubicacion de ojo y
            wOjo1_ = ojos[1].width; // ancho de ojo
            hOjo1_ = ojos[1].height;// alto de ojo 

            ojosDatos[0][item] = xOjo0_;
            ojosDatos[1][item] = yOjo0_;
            ojosDatos[2][item] = wOjo0_;
            ojosDatos[3][item] = hOjo0_;

            ojosDatos[4][item] = xOjo1_;
            ojosDatos[5][item] = yOjo1_;
            ojosDatos[6][item] = wOjo1_;
            ojosDatos[7][item] = hOjo1_;


            println("Ojos: ", ojosDatos[0][item], ojosDatos[1][item], ojosDatos[2][item] 
              , ojosDatos[3][item], ojosDatos[4][item], 
              ojosDatos[5][item], 
              ojosDatos[6][item], 
              ojosDatos[7][item] );
            strokeWeight(1);
            stroke(#00FF00);
            rect(ojosDatos[0][item], ojosDatos[1][item], ojosDatos[2][item], ojosDatos[3][item]);
            rect(ojosDatos[4][item], ojosDatos[5][item], ojosDatos[6][item], ojosDatos[7][item]);
          } else { //Error handler ojos
            //println("Error en ojos");
          }
          //En cada cara hay una nariz y esta debajo de los ojos
          if ((nariz.length == 1) 
            && ((nariz[0].x > caraDatos[0][item])&&(nariz[0].x < caraDatos[0][item]+caraDatos[2][item]))
            && ((nariz[0].y > caraDatos[1][item])&&(nariz[0].y < caraDatos[1][item]+caraDatos[3][item]))
            && ((nariz[0].y > ojosDatos[1][item])&&(nariz[0].y < caraDatos[1][item]+caraDatos[3][item]))

            ) { //Si detecta la nariz dentro del area de la cara dibuja la nariz
            xNariz_ = nariz[0].x; // ubicacion de ojo x
            yNariz_ = nariz[0].y; // ubicacion de ojo y
            wNariz_ = nariz[0].width; // ancho de ojo
            hNariz_ = nariz[0].height;// alto de ojo 

            narizDatos[0][item] = xNariz_;
            narizDatos[1][item] = yNariz_;
            narizDatos[2][item] = wNariz_;
            narizDatos[3][item] = hNariz_;

            strokeWeight(3);
            stroke(#0000FF);
            rect(narizDatos[0][item], narizDatos[1][item], narizDatos[2][item], narizDatos[3][item]);
          } else {//Error Handler Nariz
            //println("Error en Nariz");
          }

          //En cada cara hay una boca
          if ((boca.length != 0) 
            && ((boca[0].y > narizDatos[1][item])&&(boca[0].y < caraDatos[1][item]+caraDatos[3][item]))
            && ((boca[0].x > caraDatos[0][item])&&(boca[0].x < caraDatos[0][item]+caraDatos[2][item]))
            && ((boca[0].y > caraDatos[1][item])&&(boca[0].y < caraDatos[1][item]+caraDatos[3][item]-boca[0].height/2))
            ) { //Si detecta la boca debajo de la nariz y dentro del area de la cara dibuja la nariz
            //println(boca.length, boca[0].x, boca[0].y);
            xBoca_ = boca[0].x; // ubicacion de ojo x
            yBoca_ = boca[0].y; // ubicacion de ojo y
            wBoca_ = boca[0].width; // ancho de ojo
            hBoca_ = boca[0].height;// alto de ojo 

            bocaDatos[0][item] = xBoca_; // ubicacion de ojo x
            bocaDatos[1][item] = yBoca_; // ubicacion de ojo y
            bocaDatos[2][item] = wBoca_; // ancho de ojo
            bocaDatos[3][item] = hBoca_;// alto de ojo 
            strokeWeight(3);
            stroke(#FFFFFF);
            rect(bocaDatos[0][item], bocaDatos[1][item], bocaDatos[2][item], bocaDatos[3][item]);
          } else { // Error Handler de la boca
            //println("Error en Boca");
          }
          grafica(4, item);
        }
      }
    }
  } else { // Error Handler Cara Si no detecta cara no hay alguien
    //println("Error en Cara");
    hayAlguien= false;
  }
  return hayAlguien;
}

void grafica(int limite, int itm ) {
  int cuantosC  = 0;
  int cuantosO  = 0;
  int cuantosB  = 0;
  int cuantosN = 0;
  for (int i = 0; i <= limite-1; i++ ) {
    //println(cuantos ,caraDatos[i][itm]);
    if ( caraDatos[i][itm] != 0) {
      cuantosC++;
    } else if (caraDatos[i][itm] == 0) {
      cuantosC--;
    }
  }
  cuantosC = cuantosC * 10;
  fill(#ff0000);
  noStroke();
  rect(0, 10, 5, cuantosC);

  for (int i = 0; i <= (limite*2)-1; i++ ) {
    //println(cuantos ,caraDatos[i][itm]);
    if ( ojosDatos[i][itm] != 0) {
      cuantosO++;
    } else if (ojosDatos[i][itm] == 0) {
      cuantosO--;
    }
  }
  cuantosO = cuantosO/2 * 10;
  fill(#00FF00);
  noStroke();
  rect(-5, 10, 5, cuantosO);

  for (int i = 0; i <= limite-1; i++ ) {
    //println(cuantos ,caraDatos[i][itm]);
    if ( narizDatos[i][itm] != 0) {
      cuantosN++;
    } else if (narizDatos[i][itm] == 0) {
      cuantosN--;
    }
  }
  cuantosN = cuantosN * 10;
  fill(#0000ff);
  noStroke();
  rect(5, 10, 5, cuantosN);

  for (int i = 0; i <= limite-1; i++ ) {
    //println(cuantos ,caraDatos[i][itm]);
    if ( bocaDatos[i][itm] != 0) {
      cuantosB++;
    } else if (bocaDatos[i][itm] == 0) {
      cuantosB--;
    }
  }
  cuantosB = cuantosB * 10;
  fill(#ffffff);
  stroke(0);
  strokeWeight(.5);
  rect(-10, 10, 5, cuantosB);
}

void writeData() {
  //Cara
  output.println("--Cara--");  
  //println("--Cara--");  
  for (int columna = 0; columna <= 3; columna++) { 
    for (int fila = 0; fila <= numMuestras-1; fila++) {
      output.println(columna+ ": " +caraDatos[columna][fila]);
      //  println(columna+ ": " +caraDatos[columna][fila]);
    }
  }
  //Ojos
  output.println("--Ojos--"); 
  println("--Ojos--"); 
  for (int columna = 0; columna <= 7; columna++) {
    for (int fila = 0; fila <= numMuestras-1; fila++) {
      output.println(columna+ ": " +ojosDatos[columna][fila]);
      println(columna+ ": " +ojosDatos[columna][fila]);
    }
  }
  //Boca
  output.println("--Boca--"); 
  //println("--Boca--"); 
  for (int columna = 0; columna <= 3; columna++) {
    for (int fila = 0; fila <= numMuestras-1; fila++) {
      output.println(columna+ ": " +bocaDatos[columna][fila]);
      //  println(columna+ ": " +bocaDatos[columna][fila]);
    }
  }
  //Nariz
  output.println("--Nariz--"); 
  //println("--Nariz--"); 
  for (int columna = 0; columna <= 3; columna++) {
    for (int fila = 0; fila <= numMuestras-1; fila++) {
      output.println(columna+ ": " +bocaDatos[columna][fila]);
      //  println(columna+ ": " +bocaDatos[columna][fila]);
    }
  }
  output.flush();
  output.close();
}