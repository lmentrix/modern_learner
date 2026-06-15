import 'package:modern_learner_production/study/model/study_models.dart';

const mockNotes = [
  StudyNote(
    id: '1',
    title: 'Intro to Neural Networks',
    subject: 'Machine Learning',
    preview: 'A neural network is a series of algorithms that recognise underlying relationships in a set of data...',
    createdAt: 'Jun 12',
    tagColor: 0xFFBBF0D9,
    readMinutes: 6,
    body: '''A neural network is a series of algorithms that recognise underlying relationships in a set of data through a process that mimics the way the human brain operates.

Neural networks can adapt to changing input so the network generates the best possible result without needing to redesign the output criteria.

## Layers

Every neural network consists of layers of nodes — an input layer, one or more hidden layers, and an output layer. Each node, or artificial neuron, connects to another and has an associated weight and threshold.

If the output of any individual node is above the specified threshold value, that node is activated and sends data to the next layer of the network. Otherwise, no data is passed to the next layer of the network.

## Activation Functions

Activation functions decide whether a neuron should be activated or not. Common choices include:

- **ReLU** (Rectified Linear Unit): returns 0 for negative input, linear for positive input.
- **Sigmoid**: squashes values between 0 and 1, useful for binary classification.
- **Softmax**: converts logits to a probability distribution for multi-class output.

## Training

Training a neural network involves forward propagation, loss calculation, and backpropagation. The optimizer adjusts weights to minimise the loss function over many iterations (epochs).

The learning rate controls how large each weight update step is. Too high and the model diverges; too low and training is slow or gets stuck in local minima.

## Overfitting

Overfitting happens when the model learns the training data too well and fails to generalise. Techniques to prevent it include dropout, L2 regularisation, and early stopping.
''',
  ),
  StudyNote(
    id: '2',
    title: 'The Stoic Mindset',
    subject: 'Philosophy',
    preview: 'Stoicism teaches that virtue is the highest good and that external events are beyond our control...',
    createdAt: 'Jun 10',
    tagColor: 0xFFE9D5FF,
    readMinutes: 4,
    body: '''Stoicism is a school of Hellenistic philosophy that flourished throughout the Roman and Greek world until the 3rd century AD. At its core, Stoicism teaches that virtue is the highest good and that external events are outside our control.

## The Dichotomy of Control

Epictetus, a former slave who became one of the most influential Stoic philosophers, summarised the central insight: some things are in our control and others are not.

In our control: our opinions, motivations, desires, and aversions.
Not in our control: our body, reputation, property, command — everything else.

## Negative Visualisation

A key Stoic practice is *premeditatio malorum* — the premeditation of evils. By imagining the worst-case scenario, we appreciate what we have and reduce anxiety about potential loss.

## Memento Mori

"Remember you will die." Far from being morbid, this practice grounds the Stoic in the present and helps prioritise what truly matters.

## Marcus Aurelius

The *Meditations* of Marcus Aurelius represent the purest form of Stoic self-examination. Written as personal journal entries, they were never meant for publication — making them a uniquely honest philosophical document.

"You have power over your mind, not outside events. Realise this, and you will find strength."
''',
  ),
  StudyNote(
    id: '3',
    title: 'Photosynthesis Deep Dive',
    subject: 'Biology',
    preview: 'Photosynthesis is the process by which plants convert light energy into chemical energy stored in glucose...',
    createdAt: 'Jun 8',
    tagColor: 0xFFFDE68A,
    readMinutes: 5,
    body: '''Photosynthesis is the process by which plants, algae, and some bacteria convert light energy — usually from the sun — into chemical energy stored in glucose.

## The Overall Equation

6CO₂ + 6H₂O + light energy → C₆H₁₂O₆ + 6O₂

Carbon dioxide and water are converted into glucose and oxygen using light energy.

## The Light-Dependent Reactions

These reactions take place in the thylakoid membranes of the chloroplast. Light energy is absorbed by chlorophyll and used to:

1. Split water molecules (photolysis), releasing oxygen as a by-product.
2. Produce ATP and NADPH, which carry energy to the next stage.

## The Calvin Cycle

The Calvin cycle occurs in the stroma of the chloroplast. Using ATP and NADPH from the light reactions, carbon dioxide is fixed into three-carbon compounds that are eventually built into glucose.

## Limiting Factors

The rate of photosynthesis is affected by:
- **Light intensity**: more light increases the rate up to a saturation point.
- **CO₂ concentration**: more CO₂ increases the rate.
- **Temperature**: enzymes work faster up to an optimum temperature, then denature.

## Chlorophyll

Chlorophyll absorbs red and blue light most effectively and reflects green light — which is why plants appear green.
''',
  ),
];
