import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer song;
BeatDetect beat;
FFT fft;
float irisSize = 50; // Initial size of the eye's iris
int numStars = 900; // Total number of stars in the background
PVector[] stars;
float[] starSpeeds;
int[] starColors; // Store unique colors for each star

void setup() {
    size(800, 600, P3D);
    minim = new Minim(this);
    song = minim.loadFile("song.mp3", 2048);
    song.play();

    beat = new BeatDetect();
    fft = new FFT(song.bufferSize(), song.sampleRate());
    stars = new PVector[numStars];
    starSpeeds = new float[numStars];
    starColors = new int[numStars];
    for (int i = 0; i < numStars; i++) {
        stars[i] = new PVector(random(width), random(height), random(1, 5));
        starSpeeds[i] = random(1, 3);
        starColors[i] = color(255); // Initialize colors as white
    }
    colorMode(HSB, 255);
    noCursor();
}

void draw() {
    background(0); // Start with a black background
    fft.forward(song.mix); // Analyze the audio data
    updateBackground(); // Update background based on music
    drawUniverse(); // Draw stars
    translate(width / 2, height / 2);

    updateIrisSize(); // Update the size of the iris based on the beat
    drawEye(); // Draw the central eye
    drawPupil(); // Draw the pupil within the eye
}

void updateBackground() {
    float avg = 0;
    for (int i = 0; i < fft.specSize(); i++) {
        avg += fft.getBand(i);
    }
    avg /= fft.specSize();
    int bgColor = color(200, 100, avg * 10 % 255); // Color changes based on the average amplitude
    background(bgColor);
}

void updateIrisSize() {
    beat.detect(song.mix);
    if (beat.isOnset()) {
        irisSize = random(60, 120);
    } else {
        irisSize *= 0.95;
    }
}

void drawEye() {
    fill(0, 0, 255);
    stroke(255);
    ellipse(0, 0, irisSize, irisSize);
}

void drawPupil() {
    fill(0);
    ellipse(0, 0, irisSize * 0.4, irisSize * 0.4);
}

void drawUniverse() {
    for (int i = 0; i < numStars; i++) {
        float freq = fft.getBand((int)(stars[i].z * 10));
        starColors[i] = color(freq * 10 % 255, 255, 255); // Change star colors based on frequency
        stroke(starColors[i]);
        strokeWeight(stars[i].z);
        stars[i].x += starSpeeds[i];
        if (stars[i].x > width) stars[i].x = 0;
        point(stars[i].x, stars[i].y);
    }
}

void stop() {
    song.close();
    minim.stop();
    super.stop();
}
