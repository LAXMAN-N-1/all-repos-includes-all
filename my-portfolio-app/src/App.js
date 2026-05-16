import React, { useState, useEffect, useRef } from 'react';
import { motion, useScroll, useTransform } from 'framer-motion';

// Helper for smooth scrolling
const scrollToSection = (id) => {
  const element = document.getElementById(id);
  if (element) {
    element.scrollIntoView({ behavior: 'smooth' });
  }
};

// Reusable Floating Card Component (used in Hero section)
const FloatingCard = ({ children, className, delay = 0, initialY = 50, onClick }) => {
  const ref = useRef(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ['start end', 'end start']
  });
  const y = useTransform(scrollYProgress, [0, 1], [initialY, -initialY]);

  return (
    <motion.div
      ref={ref}
      className={`relative rounded-xl p-6 shadow-lg backdrop-blur-sm bg-white/70 ${className}`}
      initial={{ opacity: 0, scale: 0.8, y: 50 }}
      animate={{ opacity: 1, scale: 1, y: 0 }}
      transition={{ type: 'spring', stiffness: 100, damping: 10, delay }}
      style={{ y }}
      whileHover={{ scale: 1.05, rotate: 2 }}
      viewport={{ once: true, amount: 0.5 }}
      onClick={onClick} // Added onClick prop
    >
      {children}
    </motion.div>
  );
};

// Message Modal Component
const MessageModal = ({ isOpen, onClose }) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-dark-gray bg-opacity-75 flex items-center justify-center z-50 p-4">
      <motion.div
        className="bg-white rounded-xl shadow-2xl p-8 max-w-md w-full text-center relative"
        initial={{ opacity: 0, scale: 0.8 }}
        animate={{ opacity: 1, scale: 1 }}
        exit={{ opacity: 0, scale: 0.8 }}
        transition={{ type: 'spring', stiffness: 100, damping: 10 }}
      >
        <h3 className="text-3xl font-bold text-coral mb-4">Messages</h3>
        <p className="text-lg text-dark-gray mb-6">
          This is where you would see your messages! Currently, this is a placeholder for future functionality.
        </p>
        <button
          onClick={onClose}
          className="px-6 py-2 rounded-full bg-soft-red text-white font-semibold text-lg hover:bg-coral transition-all duration-300 shadow-md"
        >
          Close
        </button>
      </motion.div>
    </div>
  );
};


// Section Components

const Hero = ({ onShowMessages }) => { // Added onShowMessages prop
  return (
    <section id="hero" className="relative h-screen flex flex-col items-center justify-center bg-peach-white text-dark-gray overflow-hidden p-4">
      <motion.h1
        className="text-5xl md:text-7xl font-bold text-coral mb-8 text-center"
        initial={{ opacity: 0, y: -50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ type: 'spring', stiffness: 80, damping: 10, delay: 0.2 }}
      >
        Hi, I’m Laxman
      </motion.h1>
      <motion.p
        className="text-xl md:text-2xl text-dark-gray mb-12 text-center max-w-2xl"
        initial={{ opacity: 0, y: 50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ type: 'spring', stiffness: 80, damping: 10, delay: 0.4 }}
      >
        A passionate developer crafting engaging web experiences with a touch of creativity.
      </motion.p>

      <div className="relative w-full max-w-4xl h-64 md:h-96 flex items-center justify-center">
        <FloatingCard className="absolute top-1/4 left-1/4 -translate-x-1/2 -translate-y-1/2 w-48 h-32 md:w-64 md:h-40 bg-blush-pink/80 flex items-center justify-center text-center text-dark-gray text-lg" delay={0.6}>
          <img src="https://placehold.co/80x80/FFD6E8/1F1F1F?text=Profile" alt="Profile" className="rounded-full mb-2" />
          <p className="font-semibold">My Profile</p>
        </FloatingCard>
        <FloatingCard
          className="absolute bottom-1/4 right-1/4 translate-x-1/2 translate-y-1/2 w-48 h-32 md:w-64 md:h-40 bg-mint/80 flex items-center justify-center text-center text-dark-gray text-lg cursor-pointer"
          delay={0.8}
          onClick={onShowMessages} // Added onClick handler
        >
          <svg className="w-10 h-10 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.597 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"></path></svg>
          <p className="font-semibold">Messages</p>
        </FloatingCard>
        <FloatingCard className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-40 md:w-80 md:h-52 bg-sky-blue/80 flex flex-col items-center justify-center text-center text-dark-gray text-xl" delay={1}>
          <p className="font-bold mb-2">Explore My Work</p>
          <button
            className="px-6 py-2 rounded-full border border-dark-gray text-dark-gray hover:bg-dark-gray hover:text-white transition-all duration-300"
            onClick={() => scrollToSection('projects')}
          >
            Projects
          </button>
        </FloatingCard>
      </div>
    </section>
  );
};

const About = () => {
  // Variants for internal elements to fade in and slide up
  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        type: 'spring',
        stiffness: 100,
        damping: 20,
        delay: 0.1, // Small delay for each item
      },
    },
  };

  return (
    <section id="about" className="min-h-screen flex items-center justify-center bg-soft-gray-white p-4 py-16">
      <div // Main div is no longer a motion component
        className="max-w-4xl mx-auto bg-soft-red rounded-xl shadow-xl p-8 md:p-12 flex flex-col md:flex-row items-center gap-8 md:gap-12" // Solid soft-red
      >
        <motion.div className="flex-shrink-0"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.1 }} // Trigger when 10% of div is in view
          variants={itemVariants}
        >
          <img
            src="https://placehold.co/200x200/FF7F50/FFFFFF?text=Laxman"
            alt="Laxman Profile"
            className="rounded-full w-40 h-40 md:w-48 md:h-48 object-cover border-4 border-coral shadow-md"
          />
        </motion.div>
        <div className="text-white text-center md:text-left">
          <motion.h2 className="text-4xl font-bold text-white mb-4"
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, amount: 0.1 }}
            variants={itemVariants}
          >About Me</motion.h2>
          <motion.p className="text-lg leading-relaxed"
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, amount: 0.1 }}
            variants={itemVariants}
          >
            I'm Nagamalla Veera Durga Laxmanarao, a Computer Science graduate specializing in Artificial Intelligence and Machine Learning. I bring hands-on experience in data analysis, web development, and deep learning. My proven track record includes delivering scalable solutions using modern tech stacks such as React, Firebase, and Python-based ML frameworks.
          </motion.p>
          <motion.p className="text-lg leading-relaxed mt-4"
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, amount: 0.1 }}
            variants={itemVariants}
          >
            I am seeking a challenging full-time position to leverage my technical expertise in developing innovative AI/ML solutions and contributing to cutting-edge technology initiatives. My relevant coursework includes Python for Data Science, Agile Methodologies Development, AI Fundamentals, Machine Learning, and Deep Learning.
          </motion.p>
        </div>
      </div>
    </section>
  );
};

const Experience = () => {
  // Variants for internal elements to fade in and slide up
  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        type: 'spring',
        stiffness: 100,
        damping: 20,
        delay: 0.1, // Small delay for each item
      },
    },
  };

  return (
    <section id="experience" className="min-h-screen flex items-center justify-center bg-peach-white p-4 py-16">
      <div // Main div is no longer a motion component
        className="max-w-4xl mx-auto bg-blush-pink rounded-xl shadow-lg p-8 md:p-12 text-dark-gray cursor-pointer" // Solid blush-pink
      >
        <motion.h2 className="text-4xl font-bold text-soft-red mb-8 text-center"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.1 }}
          variants={itemVariants}
        >Experience</motion.h2>

        <motion.div className="mb-8"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.1 }}
          variants={itemVariants}
        >
          <motion.h3 className="text-2xl font-semibold text-soft-red"
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, amount: 0.1 }}
            variants={itemVariants}
          >Data Analysis Intern</motion.h3>
          <motion.p className="text-lg font-medium text-dark-gray"
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true, amount: 0.1 }}
            variants={itemVariants}
          >Futurence, Bengaluru | Jan 2025 - July 2025</motion.p>
          <motion.ul className="list-disc list-inside text-lg mt-4 space-y-2">
            <motion.li
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, amount: 0.1 }}
              variants={itemVariants}
            >Engaged full-time in comprehensive data analysis projects, processing and interpreting large datasets to extract actionable business insights.</motion.li>
            <motion.li
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, amount: 0.1 }}
              variants={itemVariants}
            >Collaborated with cross-functional teams to deliver data-driven solutions and project deliverables following established company guidelines and best practices.</motion.li>
            <motion.li
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, amount: 0.1 }}
              variants={itemVariants}
            >Utilized advanced data analysis techniques and tools to support strategic decision-making processes and optimize business operations.</motion.li>
            <motion.li
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, amount: 0.1 }}
              variants={itemVariants}
            >Developed automated reporting solutions and data visualizations to present complex findings to stakeholders in clear, accessible formats.</motion.li>
          </motion.ul>
        </motion.div>
      </div>
    </section>
  );
};

// ProjectCard component now accepts githubUrl and demoUrl
const ProjectCard = ({ title, description, tags, imageUrl, delay, githubUrl, demoUrl }) => {
  // Entirely different animation for Project Cards (rotateY on entry)
  const cardVariants = {
    hidden: { opacity: 0, y: 50, rotateY: 90 }, // Starts rotated on Y-axis, slightly below
    visible: {
      opacity: 1,
      y: 0,
      rotateY: 0,
      transition: {
        type: 'spring',
        stiffness: 120, // Snappy spring
        damping: 15,
        delay,
      },
    },
  };

  return (
    <motion.div
      className="relative rounded-xl p-6 shadow-lg bg-white/70 border border-blush-pink flex flex-col h-full cursor-pointer"
      variants={cardVariants}
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, amount: 0.3 }}
      whileHover={{
        y: -10, // Lift up
        boxShadow: "0 20px 40px rgba(0,0,0,0.3)", // More prominent shadow
        transition: { type: 'spring', stiffness: 300, damping: 10 },
      }}
    >
      <img
        src={imageUrl}
        alt={title}
        className="rounded-lg mb-4 object-cover w-full h-48"
        onError={(e) => { e.target.onerror = null; e.target.src = "https://placehold.co/400x200/D2F8D2/1F1F1F?text=Project+Image"; }}
      />
      <h3 className="text-2xl font-bold text-coral mb-2">{title}</h3>
      <p className="text-dark-gray text-base flex-grow">{description}</p>
      <div className="flex flex-wrap gap-2 mt-4">
        {tags.map((tag, index) => (
          <span key={index} className="bg-mint text-dark-gray text-sm px-3 py-1 rounded-full">
            {tag}
          </span>
        ))}
      </div>
      <div className="mt-6 flex justify-end space-x-4"> {/* Added space-x-4 for button spacing */}
        {demoUrl && (
          <a
            href={demoUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="px-5 py-2 rounded-full bg-soft-red text-white font-semibold text-lg hover:bg-coral transition-all duration-300 shadow-md"
          >
            View Demo
          </a>
        )}
        {githubUrl && (
          <a
            href={githubUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="px-5 py-2 rounded-full border border-dark-gray text-dark-gray hover:bg-dark-gray hover:text-white transition-all duration-300"
          >
            GitHub
          </a>
        )}
      </div>
    </motion.div>
  );
};

const Projects = () => {
  const projects = [
    {
      title: "Health Coach Calendar Application",
      description: "Developed a responsive web application using React (TypeScript) and Tailwind CSS for health coaches to manage client appointments with an intuitive daily calendar interface. Implemented real-time booking system for both one-time and recurring calls with intelligent overlap detection to prevent scheduling conflicts. Integrated Firebase Firestore for robust, real-time data persistence and Firebase Authentication for secure user management. Showcased full-stack serverless development capabilities with dynamic appointment display and seamless user experience.",
      tags: ["React", "TypeScript", "Tailwind CSS", "Firebase Firestore", "Firebase Auth"],
      imageUrl: "https://placehold.co/400x200/FFD6E8/1F1F1F?text=Health+Coach",
      githubUrl: "https://github.com/Laxman-N/my-calendar-app.git", // Added GitHub URL
      demoUrl: "https://gleaming-gecko-0d3281.netlify.app", // Added Demo URL
    },
    {
      title: "Edu Schema - Educational Management System",
      description: "Built a comprehensive Flask web application for educational institutions to manage courses, instructors, students, enrollments, assessments, and grades. Utilized SQLAlchemy ORM for database operations, Flask-WTF for secure form handling, and SQLite for efficient data storage. Designed modular Python architecture with structured templates and static files ensuring scalability and maintenance ease.",
      tags: ["Flask", "SQLAlchemy", "SQLite", "Python", "Flask-WTB"],
      imageUrl: "https://placehold.co/400x200/A3D5FF/1F1F1F?text=Edu+Schema",
      githubUrl: "https://github.com/Laxman-N/edu-schema.git", // Added GitHub URL
      demoUrl: null, // No demo URL provided for this project
    },
    {
      title: "Tensor Cancer Detection System",
      description: "Developed a Convolutional Neural Network (CNN) model using Keras and TensorFlow to classify medical images for cancer detection. Implemented advanced image preprocessing techniques using Python, NumPy, and data generators for efficient dataset handling. Designed CNN architecture with optimized convolutional and pooling layers, achieving high accuracy using categorical cross-entropy loss and RMSprop optimizer. Leveraged Google Colab for model training and experimentation, demonstrating proficiency in cloud-based ML development.",
      tags: ["CNN", "Keras", "TensorFlow", "Python", "NumPy", "Google Colab"],
      imageUrl: "https://placehold.co/400x200/FF7F50/FFFFFF?text=Cancer+Detection",
      githubUrl: null, // No GitHub URL provided for this project
      demoUrl: null, // No demo URL provided for this project
    },
  ];

  return (
    <section id="projects" className="min-h-screen bg-peach-white p-4 py-16">
      <div className="max-w-6xl mx-auto">
        <h2 className="text-5xl font-bold text-center text-soft-red mb-12">My Projects</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {projects.map((project, index) => (
            <ProjectCard key={index} {...project} delay={index * 0.1} />
          ))}
        </div>
      </div>
    </section>
  );
};

const SkillIcon = ({ icon, name, delay }) => {
  return (
    <motion.div
      className="flex flex-col items-center justify-center p-4 bg-white/70 rounded-xl shadow-md text-dark-gray"
      initial={{ opacity: 0, scale: 0.8 }}
      whileInView={{ opacity: 1, scale: 1 }}
      transition={{ type: 'spring', stiffness: 100, damping: 10, delay }}
      viewport={{ once: true, amount: 0.5 }}
      whileHover={{ scale: 1.1, rotate: 5 }}
    >
      <div className="text-5xl mb-2">{icon}</div>
      <p className="text-lg font-semibold text-center">{name}</p>
    </motion.div>
  );
};

const Skills = () => {
  const skills = [
    { icon: '💻', name: 'React.js' },
    { icon: '🚀', name: 'Next.js' },
    { icon: '🎨', name: 'Tailwind CSS' },
    { icon: '⚙️', name: 'JavaScript' },
    { icon: '🌐', name: 'HTML5' },
    { icon: '✨', name: 'CSS3' },
    { icon: '💾', name: 'Node.js' },
    { icon: '📊', name: 'Git' },
    { icon: '☁️', name: 'Firebase' },
    { icon: '🐍', name: 'Python' },
    { icon: '🧠', name: 'TensorFlow' },
    { icon: '🔬', name: 'Keras' },
    { icon: '📈', name: 'NumPy' },
    { icon: '🤖', name: 'Machine Learning' },
    { icon: '👁️', name: 'Computer Vision' },
    { icon: '🗣️', name: 'NLP' },
    { icon: '🗄️', name: 'SQL' },
    { icon: '🗃️', name: 'SQLite' },
    { icon: '🔥', name: 'Firestore' },
  ];

  return (
    <section id="skills" className="min-h-screen flex items-center justify-center bg-soft-gray-white p-4 py-16">
      <div className="max-w-6xl mx-auto text-center">
        <h2 className="text-5xl font-bold text-coral mb-12">My Skills</h2>
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6">
          {skills.map((skill, index) => (
            <SkillIcon key={index} {...skill} delay={index * 0.08} />
          ))}
        </div>
      </div>
    </section>
  );
};

const Contact = () => {
  // NEW: Distinct "zoom-in and rotate" animation for Contact
  const containerVariants = {
    hidden: { opacity: 0, scale: 0.5, rotate: 15 },
    visible: {
      opacity: 1,
      scale: 1,
      rotate: 0,
      transition: {
        type: 'spring',
        stiffness: 100,
        damping: 10,
        delay: 0.7,
      },
    },
  };

  return (
    <section id="contact" className="min-h-screen flex items-center justify-center bg-soft-gray-white p-4 py-16">
      <motion.div
        className="max-w-md mx-auto bg-mint rounded-xl shadow-xl p-8 md:p-10 text-dark-gray" // Solid mint
        variants={containerVariants}
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, amount: 0.6 }} // Increased viewport amount
      >
        <h2 className="text-4xl font-bold text-coral mb-6 text-center">Get in Touch</h2
        ><form className="space-y-6">
          <div>
            <label htmlFor="name" className="block text-lg font-medium mb-2">Name</label>
            <input
              type="text"
              id="name"
              className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-soft-red focus:border-transparent transition-all duration-200 bg-white/60"
              placeholder="Your Name"
            />
          </div>
          <div>
            <label htmlFor="email" className="block text-lg font-medium mb-2">Email</label>
            <input
              type="email"
              id="email"
              className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-soft-red focus:border-transparent transition-all duration-200 bg-white/60"
              placeholder="your@example.com"
            />
          </div>
          <div>
            <label htmlFor="message" className="block text-lg font-medium mb-2">Message</label>
            <textarea
              id="message"
              rows="5"
              className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-soft-red focus:border-transparent transition-all duration-200 bg-white/60 resize-y"
              placeholder="Your message here..."
            ></textarea>
          </div>
          <button
            type="submit"
            className="w-full px-6 py-3 rounded-full bg-soft-red text-white font-semibold text-lg hover:bg-coral transition-all duration-300 shadow-md"
          >
            Send Message
          </button>
        </form>

        <div className="mt-8 text-center">
          <h3 className="text-2xl font-bold text-soft-red mb-4">Connect with me:</h3>
          <div className="flex justify-center space-x-6">
            <motion.a
              href="https://github.com/Laxman-N" // Your GitHub URL
              target="_blank"
              rel="noopener noreferrer"
              className="text-dark-gray hover:text-coral transition-colors duration-300 text-4xl"
              whileHover={{ scale: 1.2, rotate: 5 }}
            >
              <span role="img" aria-label="GitHub">🐙</span> {/* GitHub Octocat Emoji */}
            </motion.a>
            <motion.a
              href="https://www.linkedin.com/in/laxman-6053a521a/" // Updated LinkedIn URL
              target="_blank"
              rel="noopener noreferrer"
              className="text-dark-gray hover:text-coral transition-colors duration-300 text-4xl"
              whileHover={{ scale: 1.2, rotate: 5 }}
            >
              <span role="img" aria-label="LinkedIn">🔗</span> {/* Link Emoji for LinkedIn */}
            </motion.a>
            <motion.a
              href="mailto:laxmanlaxman1629@gmail.com" // Your email
              className="text-dark-gray hover:text-coral transition-colors duration-300 text-4xl"
              whileHover={{ scale: 1.2, rotate: 5 }}
            >
              <span role="img" aria-label="Email">📧</span> {/* Email Emoji */}
            </motion.a>
          </div>
        </div>
      </motion.div>
    </section>
  );
};

const FooterNav = () => {
  const navItems = [
    { id: 'hero', icon: '🏠', label: 'Home' },
    { id: 'about', icon: '👤', label: 'About' },
    { id: 'experience', icon: '🛠️', label: 'Experience' }, // Added Experience
    { id: 'projects', icon: '💼', label: 'Projects' },
    { id: 'skills', icon: '💡', label: 'Skills' }, // Corrected emoji for Skills
    { id: 'contact', icon: '✉️', label: 'Contact' },
  ];

  const [activeSection, setActiveSection] = useState('hero');
  const sectionRefs = useRef({});

  useEffect(() => {
    const observerOptions = {
      root: null,
      rootMargin: '0px',
      threshold: 0.7, // Adjust as needed
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          setActiveSection(entry.target.id);
        }
      });
    }, observerOptions);

    // Capture the current value of sectionRefs.current in a variable
    const currentSectionRefs = sectionRefs.current;

    navItems.forEach(item => {
      const section = document.getElementById(item.id);
      if (section) {
        observer.observe(section);
        currentSectionRefs[item.id] = section; // Use the captured variable
      }
    });

    return () => {
      navItems.forEach(item => {
        const section = currentSectionRefs[item.id]; // Use the captured variable for cleanup
        if (section) {
          observer.unobserve(section);
        }
      });
    };
  }, [navItems]); // Added navItems to dependency array

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-white/90 backdrop-blur-md shadow-lg z-50 p-3 md:p-4 rounded-t-2xl border-t border-gray-200">
      <div className="flex justify-around max-w-xl mx-auto">
        {navItems.map((item) => (
          <motion.button
            key={item.id}
            className={`flex flex-col items-center justify-center p-2 rounded-lg transition-colors duration-300 ${
              activeSection === item.id ? 'text-coral' : 'text-dark-gray hover:text-soft-red'
            }`}
            onClick={() => scrollToSection(item.id)}
            whileTap={{ scale: 0.9 }}
          >
            <span className="text-2xl md:text-3xl mb-1">{item.icon}</span>
            <span className="text-xs md:text-sm font-medium hidden sm:block">{item.label}</span>
          </motion.button>
        ))}
      </div>
    </nav>
  );
};


const App = () => {
  const [showMessagesModal, setShowMessagesModal] = useState(false); // State for message modal

  return (
    // Apply global font, background, and text color using Tailwind classes
    <div className="font-inter antialiased bg-peach-white text-dark-gray">
      {/* Removed the inline <style> tag for global body styles */}
      <Hero onShowMessages={() => setShowMessagesModal(true)} /> {/* Pass handler to Hero */}
      <About />
      <Experience /> {/* New Experience Section */}
      <Projects />
      <Skills />
      <Contact />
      <FooterNav />
      {/* Add some padding at the bottom to ensure content isn't hidden by the fixed nav */}
      <div className="h-24 md:h-28"></div>

      {/* Message Modal */}
      <MessageModal
        isOpen={showMessagesModal}
        onClose={() => setShowMessagesModal(false)}
      />
    </div>
  );
};

export default App;
