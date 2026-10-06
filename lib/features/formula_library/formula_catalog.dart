import 'formula_entry.dart';

class FormulaCatalog {
  FormulaCatalog._();

  static const List<FormulaEntry> entries =
      <FormulaEntry>[
    // MATHEMATICS — ALGEBRA
    FormulaEntry(
      id: 'math_quadratic_formula',
      subject: FormulaSubject.mathematics,
      topic: 'Algebra',
      title: 'Quadratic formula',
      formula: 'x = (−b ± √(b² − 4ac)) / 2a',
      symbols:
          'a, b, c = coefficients of ax² + bx + c = 0; x = root',
      units: 'No fixed units',
      explanation:
          'Finds the roots of a quadratic equation. The discriminant D = b² − 4ac determines the nature of the roots.',
      example:
          'x² − 5x + 6 = 0 → a=1, b=−5, c=6 → x=2 or 3',
      relatedMode: 'EQN',
    ),
    FormulaEntry(
      id: 'math_discriminant',
      subject: FormulaSubject.mathematics,
      topic: 'Algebra',
      title: 'Quadratic discriminant',
      formula: 'D = b² − 4ac',
      symbols:
          'D = discriminant; a, b, c = quadratic coefficients',
      units: 'No fixed units',
      explanation:
          'D > 0 gives two distinct real roots, D = 0 gives one repeated real root, and D < 0 gives complex roots.',
      example:
          'For x² + 2x + 5 = 0: D = 4 − 20 = −16',
      relatedMode: 'EQN',
    ),
    FormulaEntry(
      id: 'math_gradient',
      subject: FormulaSubject.mathematics,
      topic: 'Coordinate Geometry',
      title: 'Gradient of a straight line',
      formula: 'm = (y₂ − y₁) / (x₂ − x₁)',
      symbols:
          'm = gradient; (x₁,y₁), (x₂,y₂) = two points',
      units: 'y-units per x-unit',
      explanation:
          'Measures the slope or rate of change of a straight line.',
      example:
          'Through (1,2) and (4,8): m = (8−2)/(4−1) = 2',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'math_distance',
      subject: FormulaSubject.mathematics,
      topic: 'Coordinate Geometry',
      title: 'Distance between two points',
      formula: 'd = √((x₂ − x₁)² + (y₂ − y₁)²)',
      symbols:
          'd = distance; (x₁,y₁), (x₂,y₂) = points',
      units: 'Same unit as coordinates',
      explanation:
          'Uses Pythagoras’ theorem to find straight-line distance.',
      example:
          '(0,0) to (3,4): d = √(9+16) = 5',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'math_midpoint',
      subject: FormulaSubject.mathematics,
      topic: 'Coordinate Geometry',
      title: 'Midpoint',
      formula: 'M = ((x₁+x₂)/2, (y₁+y₂)/2)',
      symbols:
          'M = midpoint; (x₁,y₁), (x₂,y₂) = endpoints',
      units: 'Same units as coordinates',
      explanation:
          'Finds the point exactly halfway between two endpoints.',
      example:
          '(2,4) and (6,10) → M = (4,7)',
      relatedMode: 'COMP',
    ),

    // MATHEMATICS — TRIGONOMETRY
    FormulaEntry(
      id: 'math_pythagoras',
      subject: FormulaSubject.mathematics,
      topic: 'Trigonometry',
      title: 'Pythagoras’ theorem',
      formula: 'c² = a² + b²',
      symbols:
          'c = hypotenuse; a,b = shorter sides of a right triangle',
      units: 'Length² in the equation',
      explanation:
          'Relates the three sides of a right-angled triangle.',
      example:
          'a=3, b=4 → c = √(9+16) = 5',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'math_sine_rule',
      subject: FormulaSubject.mathematics,
      topic: 'Trigonometry',
      title: 'Sine rule',
      formula: 'a/sin A = b/sin B = c/sin C',
      symbols:
          'a,b,c = sides opposite angles A,B,C',
      units: 'Lengths and angles',
      explanation:
          'Solves non-right triangles when a side-angle opposite pair is known.',
      example:
          'If a=8, A=30°, B=45° → b = 8sin45°/sin30°',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'math_cosine_rule',
      subject: FormulaSubject.mathematics,
      topic: 'Trigonometry',
      title: 'Cosine rule',
      formula: 'c² = a² + b² − 2ab cos C',
      symbols:
          'a,b,c = triangle sides; C = angle opposite c',
      units: 'Lengths and angle',
      explanation:
          'Generalizes Pythagoras’ theorem to any triangle.',
      example:
          'a=5, b=7, C=60° → c² = 25+49−35 = 39',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'math_triangle_area',
      subject: FormulaSubject.mathematics,
      topic: 'Trigonometry',
      title: 'Area of triangle using sine',
      formula: 'Area = ½ab sin C',
      symbols:
          'a,b = two sides; C = included angle',
      units: 'Square units',
      explanation:
          'Finds the area of a triangle from two sides and their included angle.',
      example:
          'a=6, b=8, C=30° → Area = 12',
      relatedMode: 'COMP',
    ),

    // MATHEMATICS — MENSURATION
    FormulaEntry(
      id: 'math_circle_area',
      subject: FormulaSubject.mathematics,
      topic: 'Mensuration',
      title: 'Area of a circle',
      formula: 'A = πr²',
      symbols: 'A = area; r = radius',
      units: 'Square units',
      explanation:
          'Finds the area enclosed by a circle.',
      example:
          'r=7 cm → A = 49π ≈ 153.94 cm²',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'math_circle_circumference',
      subject: FormulaSubject.mathematics,
      topic: 'Mensuration',
      title: 'Circumference of a circle',
      formula: 'C = 2πr = πd',
      symbols:
          'C = circumference; r = radius; d = diameter',
      units: 'Length',
      explanation:
          'Finds the distance around a circle.',
      example:
          'r=5 m → C = 10π ≈ 31.42 m',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'math_cylinder_volume',
      subject: FormulaSubject.mathematics,
      topic: 'Mensuration',
      title: 'Volume of a cylinder',
      formula: 'V = πr²h',
      symbols:
          'V = volume; r = radius; h = perpendicular height',
      units: 'Cubic units',
      explanation:
          'Volume equals circular base area multiplied by height.',
      example:
          'r=3 cm, h=10 cm → V = 90π cm³',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'math_cone_volume',
      subject: FormulaSubject.mathematics,
      topic: 'Mensuration',
      title: 'Volume of a cone',
      formula: 'V = ⅓πr²h',
      symbols: 'V = volume; r = radius; h = height',
      units: 'Cubic units',
      explanation:
          'A cone has one-third the volume of a cylinder with the same base and height.',
      example:
          'r=3 cm, h=4 cm → V = 12π cm³',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'math_sphere_volume',
      subject: FormulaSubject.mathematics,
      topic: 'Mensuration',
      title: 'Volume of a sphere',
      formula: 'V = ⁴⁄₃πr³',
      symbols: 'V = volume; r = radius',
      units: 'Cubic units',
      explanation:
          'Finds the space occupied by a sphere.',
      example:
          'r=3 cm → V = 36π cm³',
      relatedMode: 'COMP',
    ),

    // MATHEMATICS — STATISTICS/PROBABILITY
    FormulaEntry(
      id: 'math_mean',
      subject: FormulaSubject.mathematics,
      topic: 'Statistics',
      title: 'Arithmetic mean',
      formula: 'x̄ = Σx / n',
      symbols:
          'x̄ = mean; Σx = sum of values; n = number of values',
      units: 'Same unit as data',
      explanation:
          'Adds all values and divides by the number of values.',
      example:
          '2,4,6,8 → x̄ = 20/4 = 5',
      relatedMode: 'STAT',
    ),
    FormulaEntry(
      id: 'math_weighted_mean',
      subject: FormulaSubject.mathematics,
      topic: 'Statistics',
      title: 'Mean with frequency',
      formula: 'x̄ = Σfx / Σf',
      symbols:
          'f = frequency; x = value; Σf = total frequency',
      units: 'Same unit as data',
      explanation:
          'Finds the mean when each value occurs a given number of times.',
      example:
          'x: 10,20 with f: 2,1 → x̄ = (20+20)/3 = 13.33',
      relatedMode: 'STAT',
    ),
    FormulaEntry(
      id: 'math_probability',
      subject: FormulaSubject.mathematics,
      topic: 'Probability',
      title: 'Basic probability',
      formula: 'P(E) = favourable outcomes / total outcomes',
      symbols: 'P(E) = probability of event E',
      units: 'No units; 0 ≤ P ≤ 1',
      explanation:
          'For equally likely outcomes, probability is favourable outcomes divided by all possible outcomes.',
      example:
          'Rolling an even number on a fair die → 3/6 = 1/2',
      relatedMode: 'COMP',
    ),

    // MATHEMATICS — SEQUENCES / CALCULUS
    FormulaEntry(
      id: 'math_ap_nth',
      subject: FormulaSubject.mathematics,
      topic: 'Sequences & Series',
      title: 'Arithmetic progression nth term',
      formula: 'Tₙ = a + (n−1)d',
      symbols:
          'a = first term; d = common difference; n = term number',
      units: 'Same as sequence terms',
      explanation:
          'Finds any term of an arithmetic progression.',
      example:
          'a=3, d=5, n=6 → T₆ = 28',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'math_ap_sum',
      subject: FormulaSubject.mathematics,
      topic: 'Sequences & Series',
      title: 'Sum of arithmetic progression',
      formula: 'Sₙ = n/2[2a + (n−1)d]',
      symbols:
          'Sₙ = sum; a = first term; d = common difference',
      units: 'Same as sequence terms',
      explanation:
          'Finds the sum of the first n terms of an arithmetic progression.',
      example:
          'a=2, d=3, n=5 → S₅ = 40',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'math_gp_nth',
      subject: FormulaSubject.mathematics,
      topic: 'Sequences & Series',
      title: 'Geometric progression nth term',
      formula: 'Tₙ = arⁿ⁻¹',
      symbols:
          'a = first term; r = common ratio; n = term number',
      units: 'Same as sequence terms',
      explanation:
          'Finds any term of a geometric progression.',
      example:
          'a=2, r=3, n=4 → T₄ = 54',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'math_derivative_power',
      subject: FormulaSubject.mathematics,
      topic: 'Calculus Basics',
      title: 'Power rule for differentiation',
      formula: 'd/dx(xⁿ) = nxⁿ⁻¹',
      symbols: 'n = constant exponent',
      units: 'Depends on x and function',
      explanation:
          'Basic differentiation rule for powers of x.',
      example:
          'd/dx(3x⁴) = 12x³',
      relatedMode: 'COMP',
    ),

    // PHYSICS — MOTION
    FormulaEntry(
      id: 'physics_speed',
      subject: FormulaSubject.physics,
      topic: 'Motion',
      title: 'Speed',
      formula: 'v = d / t',
      symbols:
          'v = speed; d = distance; t = time',
      units: 'm/s',
      explanation:
          'Speed is distance travelled per unit time.',
      example:
          '150 m in 30 s → v = 5 m/s',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'physics_acceleration',
      subject: FormulaSubject.physics,
      topic: 'Motion',
      title: 'Acceleration',
      formula: 'a = (v − u) / t',
      symbols:
          'a = acceleration; u = initial velocity; v = final velocity',
      units: 'm/s²',
      explanation:
          'Acceleration is the rate of change of velocity.',
      example:
          'u=5 m/s, v=25 m/s, t=4 s → a=5 m/s²',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'physics_suvat_1',
      subject: FormulaSubject.physics,
      topic: 'Motion',
      title: 'First equation of uniformly accelerated motion',
      formula: 'v = u + at',
      symbols:
          'u = initial velocity; v = final velocity; a = acceleration; t = time',
      units: 'SI: m/s, m/s², s',
      explanation:
          'Relates velocity, acceleration and time for constant acceleration.',
      example:
          'u=0, a=2 m/s², t=5 s → v=10 m/s',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'physics_suvat_2',
      subject: FormulaSubject.physics,
      topic: 'Motion',
      title: 'Displacement under constant acceleration',
      formula: 's = ut + ½at²',
      symbols:
          's = displacement; u = initial velocity; a = acceleration; t = time',
      units: 'm',
      explanation:
          'Finds displacement when acceleration is constant.',
      example:
          'u=3 m/s, a=2 m/s², t=4 s → s=28 m',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'physics_suvat_3',
      subject: FormulaSubject.physics,
      topic: 'Motion',
      title: 'Velocity-displacement relation',
      formula: 'v² = u² + 2as',
      symbols:
          'u = initial velocity; v = final velocity; a = acceleration; s = displacement',
      units: 'SI consistent units',
      explanation:
          'Useful when time is not given.',
      example:
          'u=0, a=5, s=10 → v=10 m/s',
      relatedMode: 'COMP',
    ),

    // PHYSICS — FORCE / ENERGY / MOMENTUM
    FormulaEntry(
      id: 'physics_newton_second',
      subject: FormulaSubject.physics,
      topic: 'Forces',
      title: 'Newton’s second law',
      formula: 'F = ma',
      symbols: 'F = force; m = mass; a = acceleration',
      units: 'N = kg·m/s²',
      explanation:
          'Resultant force equals mass multiplied by acceleration.',
      example:
          'm=4 kg, a=3 m/s² → F=12 N',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'physics_weight',
      subject: FormulaSubject.physics,
      topic: 'Forces',
      title: 'Weight',
      formula: 'W = mg',
      symbols:
          'W = weight; m = mass; g = gravitational field strength',
      units: 'N',
      explanation:
          'Weight is the gravitational force acting on a mass.',
      example:
          'm=10 kg, g=9.8 m/s² → W=98 N',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'physics_work',
      subject: FormulaSubject.physics,
      topic: 'Work, Energy & Power',
      title: 'Work done',
      formula: 'W = Fd cos θ',
      symbols:
          'W = work; F = force; d = displacement; θ = angle between F and d',
      units: 'J',
      explanation:
          'Work equals the component of force along displacement multiplied by distance.',
      example:
          'F=10 N, d=5 m, θ=0° → W=50 J',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'physics_ke',
      subject: FormulaSubject.physics,
      topic: 'Work, Energy & Power',
      title: 'Kinetic energy',
      formula: 'KE = ½mv²',
      symbols: 'm = mass; v = speed',
      units: 'J',
      explanation:
          'Energy possessed by a body because of its motion.',
      example:
          'm=2 kg, v=6 m/s → KE=36 J',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'physics_gpe',
      subject: FormulaSubject.physics,
      topic: 'Work, Energy & Power',
      title: 'Gravitational potential energy',
      formula: 'GPE = mgh',
      symbols:
          'm = mass; g = gravitational field strength; h = height',
      units: 'J',
      explanation:
          'Energy gained by raising a mass through a vertical height.',
      example:
          'm=5 kg, g=10 m/s², h=4 m → 200 J',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'physics_power',
      subject: FormulaSubject.physics,
      topic: 'Work, Energy & Power',
      title: 'Power',
      formula: 'P = W / t',
      symbols: 'P = power; W = work/energy; t = time',
      units: 'W (watt)',
      explanation:
          'Power is the rate at which work is done or energy is transferred.',
      example:
          '600 J in 3 s → P=200 W',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'physics_momentum',
      subject: FormulaSubject.physics,
      topic: 'Momentum',
      title: 'Momentum',
      formula: 'p = mv',
      symbols: 'p = momentum; m = mass; v = velocity',
      units: 'kg·m/s',
      explanation:
          'Momentum is the product of mass and velocity.',
      example:
          'm=4 kg, v=5 m/s → p=20 kg·m/s',
      relatedMode: 'COMP',
    ),

    // PHYSICS — WAVES / ELECTRICITY / HEAT / PRESSURE / OPTICS
    FormulaEntry(
      id: 'physics_wave',
      subject: FormulaSubject.physics,
      topic: 'Waves',
      title: 'Wave speed',
      formula: 'v = fλ',
      symbols:
          'v = wave speed; f = frequency; λ = wavelength',
      units: 'm/s, Hz, m',
      explanation:
          'Relates wave speed to frequency and wavelength.',
      example:
          'f=50 Hz, λ=2 m → v=100 m/s',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'physics_ohm',
      subject: FormulaSubject.physics,
      topic: 'Electricity',
      title: 'Ohm’s law',
      formula: 'V = IR',
      symbols:
          'V = voltage; I = current; R = resistance',
      units: 'V, A, Ω',
      explanation:
          'For an ohmic conductor at constant conditions, voltage equals current times resistance.',
      example:
          'I=2 A, R=6 Ω → V=12 V',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'physics_electric_power',
      subject: FormulaSubject.physics,
      topic: 'Electricity',
      title: 'Electrical power',
      formula: 'P = VI = I²R = V²/R',
      symbols:
          'P = power; V = voltage; I = current; R = resistance',
      units: 'W',
      explanation:
          'Equivalent forms for electrical power depending on known quantities.',
      example:
          'V=12 V, I=3 A → P=36 W',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'physics_charge',
      subject: FormulaSubject.physics,
      topic: 'Electricity',
      title: 'Electric charge',
      formula: 'Q = It',
      symbols: 'Q = charge; I = current; t = time',
      units: 'C',
      explanation:
          'Charge transferred equals current multiplied by time.',
      example:
          'I=2 A for 5 s → Q=10 C',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'physics_heat',
      subject: FormulaSubject.physics,
      topic: 'Heat',
      title: 'Heat energy',
      formula: 'Q = mcΔT',
      symbols:
          'Q = heat; m = mass; c = specific heat capacity; ΔT = temperature change',
      units: 'J',
      explanation:
          'Energy required to change temperature without a phase change.',
      example:
          'm=2 kg, c=4200, ΔT=5°C → Q=42000 J',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'physics_pressure',
      subject: FormulaSubject.physics,
      topic: 'Pressure',
      title: 'Pressure',
      formula: 'P = F / A',
      symbols: 'P = pressure; F = normal force; A = area',
      units: 'Pa = N/m²',
      explanation:
          'Pressure is force acting per unit area.',
      example:
          'F=200 N on 0.5 m² → P=400 Pa',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'physics_density',
      subject: FormulaSubject.physics,
      topic: 'Pressure',
      title: 'Density',
      formula: 'ρ = m / V',
      symbols: 'ρ = density; m = mass; V = volume',
      units: 'kg/m³',
      explanation:
          'Density is mass per unit volume.',
      example:
          'm=6 kg, V=0.002 m³ → ρ=3000 kg/m³',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'physics_lens',
      subject: FormulaSubject.physics,
      topic: 'Optics',
      title: 'Thin lens formula',
      formula: '1/f = 1/u + 1/v',
      symbols:
          'f = focal length; u = object distance; v = image distance',
      units: 'Any consistent length unit',
      explanation:
          'Relates focal length to object and image distances using a chosen sign convention.',
      example:
          'u=30 cm, v=60 cm → f=20 cm',
      relatedMode: 'COMP',
    ),

    // CHEMISTRY — MOLES / CONCENTRATION
    FormulaEntry(
      id: 'chem_moles_mass',
      subject: FormulaSubject.chemistry,
      topic: 'Mole Calculations',
      title: 'Moles from mass',
      formula: 'n = m / M',
      symbols:
          'n = amount in moles; m = mass; M = molar mass',
      units: 'mol, g, g/mol',
      explanation:
          'Converts a measured mass to amount of substance.',
      example:
          '18 g H₂O, M=18 g/mol → n=1 mol',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'chem_particles',
      subject: FormulaSubject.chemistry,
      topic: 'Mole Calculations',
      title: 'Number of particles',
      formula: 'N = nNₐ',
      symbols:
          'N = particles; n = moles; Nₐ = Avogadro constant ≈ 6.022×10²³ mol⁻¹',
      units: 'Particle count',
      explanation:
          'Converts between moles and number of microscopic particles.',
      example:
          '0.5 mol → N ≈ 3.011×10²³ particles',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'chem_concentration',
      subject: FormulaSubject.chemistry,
      topic: 'Concentration',
      title: 'Molar concentration',
      formula: 'c = n / V',
      symbols:
          'c = concentration; n = moles; V = solution volume in dm³',
      units: 'mol/dm³',
      explanation:
          'Molar concentration is amount of solute per volume of solution.',
      example:
          '0.2 mol in 0.5 dm³ → c=0.4 mol/dm³',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'chem_dilution',
      subject: FormulaSubject.chemistry,
      topic: 'Concentration',
      title: 'Dilution equation',
      formula: 'C₁V₁ = C₂V₂',
      symbols:
          'C₁,V₁ = initial concentration/volume; C₂,V₂ = final values',
      units: 'Use consistent volume units',
      explanation:
          'For dilution, the amount of solute is conserved.',
      example:
          '2.0 mol/dm³ × 50 cm³ = 0.5 mol/dm³ × V₂ → V₂=200 cm³',
      relatedMode: 'EQN',
    ),

    // CHEMISTRY — GAS LAWS
    FormulaEntry(
      id: 'chem_boyle',
      subject: FormulaSubject.chemistry,
      topic: 'Gas Laws',
      title: 'Boyle’s law',
      formula: 'P₁V₁ = P₂V₂',
      symbols:
          'P = pressure; V = volume; temperature constant',
      units: 'Any consistent pressure and volume units',
      explanation:
          'At constant temperature for a fixed gas mass, pressure is inversely proportional to volume.',
      example:
          'P₁=100 kPa, V₁=2 L, V₂=1 L → P₂=200 kPa',
      relatedMode: 'EQN',
    ),
    FormulaEntry(
      id: 'chem_charles',
      subject: FormulaSubject.chemistry,
      topic: 'Gas Laws',
      title: 'Charles’s law',
      formula: 'V₁/T₁ = V₂/T₂',
      symbols:
          'V = volume; T = absolute temperature in kelvin',
      units: 'Volume units; K',
      explanation:
          'At constant pressure, gas volume is directly proportional to absolute temperature.',
      example:
          'V₁=2 L, T₁=300 K, T₂=450 K → V₂=3 L',
      relatedMode: 'EQN',
    ),
    FormulaEntry(
      id: 'chem_combined_gas',
      subject: FormulaSubject.chemistry,
      topic: 'Gas Laws',
      title: 'Combined gas law',
      formula: 'P₁V₁/T₁ = P₂V₂/T₂',
      symbols:
          'P = pressure; V = volume; T = kelvin temperature',
      units: 'Consistent P/V units; K',
      explanation:
          'Combines Boyle’s and Charles’s relationships for a fixed gas amount.',
      example:
          'Rearrange for the unknown pressure, volume or temperature.',
      relatedMode: 'EQN',
    ),
    FormulaEntry(
      id: 'chem_ideal_gas',
      subject: FormulaSubject.chemistry,
      topic: 'Gas Laws',
      title: 'Ideal gas equation',
      formula: 'PV = nRT',
      symbols:
          'P = pressure; V = volume; n = moles; R = gas constant; T = kelvin',
      units: 'Depends on chosen R',
      explanation:
          'Relates pressure, volume, amount and temperature of an ideal gas.',
      example:
          'Use R=8.314 J·mol⁻¹·K⁻¹ with SI units.',
      relatedMode: 'EQN',
    ),

    // CHEMISTRY — ACIDS / ELECTROCHEMISTRY / ENERGETICS
    FormulaEntry(
      id: 'chem_ph',
      subject: FormulaSubject.chemistry,
      topic: 'Acids & Bases',
      title: 'pH',
      formula: 'pH = −log₁₀[H⁺]',
      symbols: '[H⁺] = hydrogen ion concentration',
      units: 'pH has no units',
      explanation:
          'Converts hydrogen ion concentration into the pH scale.',
      example:
          '[H⁺]=1×10⁻³ mol/dm³ → pH=3',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'chem_poh',
      subject: FormulaSubject.chemistry,
      topic: 'Acids & Bases',
      title: 'pOH',
      formula: 'pOH = −log₁₀[OH⁻]',
      symbols: '[OH⁻] = hydroxide ion concentration',
      units: 'No units',
      explanation:
          'Converts hydroxide concentration to pOH.',
      example:
          '[OH⁻]=1×10⁻⁴ → pOH=4',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'chem_ph_poh',
      subject: FormulaSubject.chemistry,
      topic: 'Acids & Bases',
      title: 'pH and pOH relation',
      formula: 'pH + pOH = 14',
      symbols:
          'At approximately 25°C in dilute aqueous solution',
      units: 'No units',
      explanation:
          'Links acidity and alkalinity through the ionic product of water under standard classroom conditions.',
      example:
          'pOH=5 → pH=9',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'chem_faraday',
      subject: FormulaSubject.chemistry,
      topic: 'Electrochemistry',
      title: 'Charge in electrolysis',
      formula: 'Q = It',
      symbols:
          'Q = charge; I = current; t = time',
      units: 'C',
      explanation:
          'Electrical charge passed during electrolysis equals current multiplied by time.',
      example:
          'I=2 A for 600 s → Q=1200 C',
      relatedMode: 'COMP',
    ),
    FormulaEntry(
      id: 'chem_enthalpy',
      subject: FormulaSubject.chemistry,
      topic: 'Energetics',
      title: 'Enthalpy change from heat',
      formula: 'ΔH = Q / n',
      symbols:
          'ΔH = molar enthalpy change; Q = heat transferred; n = moles',
      units: 'Usually kJ/mol',
      explanation:
          'Relates measured heat transfer to enthalpy change per mole, with sign chosen for the process.',
      example:
          '60 kJ released by 2 mol → magnitude = 30 kJ/mol',
      relatedMode: 'COMP',
    ),
  ];

  static List<String> topicsFor(
    FormulaSubject subject,
  ) {
    final Set<String> topics = entries
        .where(
          (FormulaEntry entry) =>
              entry.subject == subject,
        )
        .map(
          (FormulaEntry entry) => entry.topic,
        )
        .toSet();

    final List<String> sorted = topics.toList()
      ..sort();

    return sorted;
  }
}
