import cv2
import numpy as np
import os

# Placeholder for a face detection model (e.g., Haar Cascade or MTCNN)
# For simplicity, using Haar Cascade here. You might need to download the XML file.
# Ensure 'haarcascade_frontalface_default.xml' is available or provide the correct path.
# You might need to install opencv-python if not already installed.

# Attempt to load the cascade classifier
try:
    # Common path within OpenCV installation or current directory
    cascade_path = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
    if not os.path.exists(cascade_path):
        # Fallback to checking the current directory or a specific known path
        cascade_path = 'haarcascade_frontalface_default.xml' # Assuming it's in the same dir or downloaded
        if not os.path.exists(cascade_path):
             # As a last resort, try a common location within the virtual environment if applicable
             # This path might vary greatly depending on the system setup
             import site
             site_packages_path = site.getsitepackages()[0]
             cascade_path = os.path.join(site_packages_path, 'cv2', 'data', 'haarcascade_frontalface_default.xml')

    if not os.path.exists(cascade_path):
        print(f"Warning: Haar cascade file not found at expected locations. Face detection might fail. Searched: {cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'}, ./haarcascade_frontalface_default.xml, and site-packages.")
        # Create a dummy classifier if file not found to avoid crashing, but detection won't work
        face_cascade = None
    else:
        print(f"Loading Haar cascade from: {cascade_path}")
        face_cascade = cv2.CascadeClassifier(cascade_path)
        if face_cascade.empty():
            print(f"Warning: Failed to load Haar cascade from {cascade_path}. Face detection might fail.")
            face_cascade = None

except Exception as e:
    print(f"Error loading Haar cascade classifier: {e}. Face detection might fail.")
    face_cascade = None

def extract_frames(video_path, num_frames=7):
    """Extracts a specified number of frames evenly spaced throughout the video."""
    frames = []
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"Error: Could not open video file: {video_path}")
        return frames

    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    if total_frames < num_frames:
        num_frames = total_frames # Adjust if video has fewer frames than requested

    frame_indices = np.linspace(0, total_frames - 1, num_frames, dtype=int)

    for i in frame_indices:
        cap.set(cv2.CAP_PROP_POS_FRAMES, i)
        ret, frame = cap.read()
        if ret:
            frames.append(frame)
        else:
            print(f"Warning: Could not read frame at index {i}")

    cap.release()
    print(f"Extracted {len(frames)} frames from {video_path}")
    return frames

def detect_and_crop_face(frame, target_size=(224, 224)):
    """Detects the largest face in a frame and crops/resizes it."""
    if face_cascade is None:
        print("Face cascade not loaded, skipping face detection.")
        # Fallback: Resize the whole frame if no face detection is possible
        return cv2.resize(frame, target_size)

    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))

    if len(faces) == 0:
        print("No faces detected in frame.")
        return None # Return None if no face is detected

    # Find the largest face
    largest_face = max(faces, key=lambda rect: rect[2] * rect[3])
    x, y, w, h = largest_face

    # Crop the face
    face_cropped = frame[y:y+h, x:x+w]

    # Resize to target size
    face_resized = cv2.resize(face_cropped, target_size)

    return face_resized

def apply_clahe(image):
    """Applies CLAHE (Contrast Limited Adaptive Histogram Equalization) to the L channel of an image in LAB color space."""
    try:
        lab = cv2.cvtColor(image, cv2.COLOR_BGR2LAB)
        l, a, b = cv2.split(lab)
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
        cl = clahe.apply(l)
        limg = cv2.merge((cl, a, b))
        final_image = cv2.cvtColor(limg, cv2.COLOR_LAB2BGR)
        return final_image
    except cv2.error as e:
        print(f"OpenCV error during CLAHE: {e}. Returning original image.")
        return image # Return original if CLAHE fails
    except Exception as e:
        print(f"Unexpected error during CLAHE: {e}. Returning original image.")
        return image

