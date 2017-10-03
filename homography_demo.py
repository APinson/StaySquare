# Anthony Kuntz
# 18-500 demo code
#
# Nothing tricky happening here, it's basically just PixelLab from 15122
#
# KEYSTONE CORRECTION DERIVED FROM THE PARAMETERS OF PROJECTORS
# https://patentimages.storage.googleapis.com/9e/8d/78/5056def0bb7426/US6997563.pdf
#

import PIL as pil
from PIL import Image
import numpy as np
from math import cos, sin

def get_homography(proj_coors, screen_coors, width=None, height=None):
    if len(proj_coors) != 4 or not all(len(e) == 2 for e in proj_coors):
        raise ValueError("Arg `proj_coors` should be contain (x,y) for 4 " \
                         "coordinates in the projector space")

    if len(screen_coors) != 4 or not all(len(e) == 2 for e in screen_coors):
        raise ValueError("Arg `screen_coors` should be contain (X,Y) for 4 " \
                         "coordinates in the screen space")

    if width and height:
        proj_coors = ((x / width, y / height) for x, y in proj_coors)
        screen_coors = ((x / width, y / width) for x, y in screen_coors)

    (x1, y1), (x2, y2), (x3, y3), (x4, y4) = proj_coors
    (X1, Y1), (X2, Y2), (X3, Y3), (X4, Y4) = screen_coors

    A = np.empty((2 * 4, 9), dtype=np.float64)

    A[0, :] = X1, Y1, 1, 0, 0, 0, -X1 * x1, -Y1 * x1, -x1
    A[1, :] = 0, 0, 0, X1, Y1, 1, -X1 * y1, -Y1 * y1, -y1

    A[2, :] = X2, Y2, 1, 0, 0, 0, -X2 * x2, -Y2 * x2, -x2
    A[3, :] = 0, 0, 0, X2, Y2, 1, -X2 * y2, -Y2 * y2, -y2

    A[4, :] = X3, Y3, 1, 0, 0, 0, -X3 * x3, -Y3 * x3, -x3
    A[5, :] = 0, 0, 0, X3, Y3, 1, -X3 * y3, -Y3 * y3, -y3

    A[6, :] = X4, Y4, 1, 0, 0, 0, -X4 * x4, -Y4 * x4, -x4
    A[7, :] = 0, 0, 0, X4, Y4, 1, -X4 * y4, -Y4 * y4, -y4

    AtA = np.dot(A.T, A)

    eigenvals, eigenvecs = np.linalg.eigh(AtA)

    for i in range(len(eigenvals)):
        print("Eigenvalue: {} Eigenvector: {}".format(eigenvals[i],
                                                      eigenvecs[:, i]))

    smallest_idx = np.argmin(eigenvals)
    small_val = eigenvals[smallest_idx]
    small_vec = eigenvecs[:, smallest_idx]

    H = small_vec.reshape((3, 3))

    print("Homography matrix:\n{}".format(H))

    return H

""" Some projectors achieve rotation by elevating the front end of the
projector: either using extendible legs, or by propping the projector, perhaps
using books.  This elevation accomplishes rotation through the vertical
YZ-plane. To achieve rotation through the horizontal plane, the projector (along
with any elevating materials) is swiveled on the table (or whatever surface the
projector is resting on). In other words, the horizontal rotation is in the
original XZ-plane, which was orthogonal to the projection surface. """
def proj_corners1(x, y, d, vert_tilt, horiz_tilt, offset, width=1920,
                  height=1080):

    x_proj_numer = cos(horiz_tilt) * x
    x_proj_denom = 1. + \
                   (sin(vert_tilt) * y + cos(vert_tilt) * sin(horiz_tilt) * x) / d
    x_proj = x_proj_numer / x_proj_denom

    y_proj_numer = cos(vert_tilt) * y - \
                   sin(horiz_tilt) * sin(vert_tilt) * x - \
                   (offset - height/2)
    y_proj_denom = 1 + \
                   (sin(vert_tilt) * y + cos(vert_tilt) * sin(horiz_tilt) * x) / d ** 6
    y_proj = y_proj_numer / y_proj_denom + (offset - width/2)

    return x_proj, y_proj

""" Some projectors using a platform that can both rotate left and right and
swivel up and down. Such a projector is not performing rotation in the original
XZ-plane: instead, it is rotating horizontally in a tilted plane. Thus, to
determine the “true” horizontal rotation (relative to the original XZ plane)
requires compensating for the fact that the projector has also been tilted
vertically. """
def proj_corners2(x, y, d, vert_tilt, horiz_tilt, offset, width=1920,
                  height=1080):

    x_proj_numer = cos(horiz_tilt) * x - \
                   sin(horiz_tilt) * cos(vert_tilt) * y
    x_proj_denom = 1 + \
                   (sin(horiz_tilt) * x - cos(horiz_tilt) * sin(vert_tilt) * y) / d
    x_proj = x_proj_numer / x_proj_denom

    y_proj_numer = cos(vert_tilt) * y - \
                   (offset - width/2)
    y_proj_denom = 1 + \
                   (sin(horiz_tilt) * x + cos(horiz_tilt) * sin(vert_tilt) * y) / d
    y_proj = y_proj_numer / y_proj_denom + (offset - height/2)

    return x_proj, y_proj

def vertical_tilt(x, y, z, tilt):
    x_proj = cos(tilt) * x - sin(tilt) * z
    y_proj = y
    z_proj = sin(tilt) * x + cos(tilt) * z

    return x_proj, y_proj, z_proj

def horizontal_tilt(x, y, z, tilt):
    x_proj = cos(tilt) * x + sin(tilt) * y
    y_proj = -sin(tilt) * x + cos(tilt) * y
    z_proj = z

    return x_proj, y_proj, z_proj

def apply_transformation(a,b,c,d,e,f,g,h,name):

    H = np.matrix([ [a, b, c],
                    [d, e, f],
                    [g, h, 1] ])


    source = Image.open(name)
    source_mat = np.array(source)

    dest = Image.new(source.mode, source.size)
    display = dest.load()

    width, height = dest.size

    for y in xrange(height):
        for x in xrange(width):

            dest_array = np.array([[x], [y], [1]])

            result = np.matmul(H,dest_array)

            x_src = min( width-1, max(0, int(round(result[0]))))
            y_src = min(height-1, max(0, int(round(result[1]))))

            display[y,x] = tuple(source_mat[y_src][x_src])

    dest.show()

def main():
    np.set_printoptions(precision=2, threshold=25, suppress=True)
    proj_coors = (0, 0), (0, 640), (480, 0), (640, 480)
    screen_coors = (64, 0), (576, 0), (480, 0), (480, 576)

    get_homography(proj_coors, screen_coors)

if __name__ == "__main__":
    main()

# identity function:
# apply_transformation(1,0,0,0,1,0,0,0,"icon.png")

#  apply_transformation(1,.2,.1,.1,1,0,0,0,"icon.png")


