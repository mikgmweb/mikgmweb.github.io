let t = 0;
function setup(){
    var can = createCanvas(750, 750);
    can.parent("super");
    noFill();
    stroke(255);
    strokeWeight(2);
}

function draw(){
    background(0);
    translate(width / 2, height / 2);
    beginShape(POINTS);
    for(let theta = 0.01;theta <= 64 * PI;theta+=0.1) {
        let rad = r(theta, 2, 2, 8, sin(t * 0.01 + PI / 4) * 0.01 + 0.5, cos(t * 0.1) * 0.5 + 0.5, sin(t * 0.1) + 0.5);
        let x = rad * cos(theta) * 50;
        let y = rad * sin(theta) * 50;
        vertex(x, y);
    }
    endShape();
    t+=0.1;
}

function r(theta, a, b, m, n1, n2, n3){
    return pow(pow(abs(cos(m * theta / 4.0) / a), n2) + pow(abs(sin(m * theta / 4.0) / b), n3), -1.0 / n1);
}

